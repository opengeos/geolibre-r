# Stripping credentials out of a project before it is written, printed, or
# handed to anyone else.
#
# Mirrors the credential registry in the application's core package: an entry
# missing here would ship a secret the application's own export path strips.

# Fold the spellings of one credential name together, so `apiKey`, `api_key`,
# `api-key`, and `APIKEY` are one entry.
normalize_credential_name <- function(name) {
  gsub("[-_]", "", tolower(name))
}

CREDENTIAL_FIELD_NAMES <- normalize_credential_name(c(
  "requestHeaders", "headers", "authorization", "apiKey", "apiKeys",
  "accessToken", "token", "password", "clientSecret", "connectionString",
  "secret", "bearer", "auth", "authKey", "sasToken", "subscriptionKey",
  "signature", "pwd"
))

# Wider than the field registry by design: `key` and the Azure shared-access
# parameters are credentials only inside a query string. As configuration field
# names they collide with ordinary state, where `sr` is a spatial reference.
CREDENTIAL_URL_PARAMS <- union(
  CREDENTIAL_FIELD_NAMES,
  normalize_credential_name(c("key", "sig", "se", "sp", "sv", "sr", "st", "skoid"))
)

# The layer fields that can carry credentials. `connection$lastError` is
# free-form text taken from a caught error, which a refresh path could easily
# build from the request URL, so it is swept too.
LAYER_CREDENTIAL_FIELDS <- c("source", "metadata", "sourcePath", "connection")

MAX_REDACT_DEPTH <- 12L

# Plugin settings that survive redaction, as plugin id to the sub-keys kept from
# its blob (NULL keeps the whole blob). A plugin's settings are free-form and a
# third-party plugin can keep an API key there, so the default is to drop all of
# it. What is listed here is map-control composition, which is what a saved
# project needs in order to render the map it was built as.
#
# The Components plugin's `html` sub-key is deliberately absent: it holds a panel
# the user authored by hand, so it can carry anything, including a URL with a
# token in it.
publishable_plugin_settings <- function() {
  settings <- list(NULL, c("legend", "colorbar"))
  names(settings) <- c(SWIPE_PLUGIN_ID, COMPONENTS_PLUGIN_ID)
  settings
}

is_credential_param <- function(pair) {
  name <- sub("=.*$", "", pair)
  decoded <- tryCatch(
    utils::URLdecode(gsub("+", " ", name, fixed = TRUE)),
    error = function(error) name
  )
  normalized <- normalize_credential_name(decoded)
  normalized %in% CREDENTIAL_URL_PARAMS || startsWith(tolower(decoded), "x-amz-")
}

keep_params <- function(query) {
  if (!nzchar(query)) return("")
  pairs <- strsplit(query, "&", fixed = TRUE)[[1]]
  pairs <- pairs[nzchar(pairs) & !vapply(pairs, is_credential_param, logical(1))]
  paste(pairs, collapse = "&")
}

#' Strip credentials from a URL
#'
#' Removes any `user:password@` prefix and any query parameter whose name marks
#' it as a credential, such as `api_key`, `access_token`, or an Azure
#' shared-access signature. The rest of the URL is left byte-for-byte intact.
#'
#' @param url A URL string.
#' @return The URL with its credentials removed.
#' @examples
#' redact_url("https://tiles.example.com/style.json?api_key=secret&lang=en")
#' redact_url("https://user:pw@example.com/data.tif")
#' @export
redact_url <- function(url) {
  if (!is_scalar_string(url)) return(url)
  hash_at <- regexpr("#", url, fixed = TRUE)
  before_hash <- if (hash_at > 0) substr(url, 1, hash_at - 1) else url
  fragment <- if (hash_at > 0) substr(url, hash_at + 1, nchar(url)) else NA_character_
  query_at <- regexpr("?", before_hash, fixed = TRUE)
  base <- if (query_at > 0) substr(before_hash, 1, query_at - 1) else before_hash
  query <- if (query_at > 0) substr(before_hash, query_at + 1, nchar(before_hash)) else NA_character_

  scheme <- regmatches(base, regexpr("^[A-Za-z][A-Za-z0-9+.-]*://", base))
  if (length(scheme) && nzchar(scheme)) {
    rest <- substr(base, nchar(scheme) + 1, nchar(base))
    slash_at <- regexpr("/", rest, fixed = TRUE)
    authority <- if (slash_at > 0) substr(rest, 1, slash_at - 1) else rest
    tail <- if (slash_at > 0) substr(rest, slash_at, nchar(rest)) else ""
    if (grepl("@", authority, fixed = TRUE)) {
      parts <- strsplit(authority, "@", fixed = TRUE)[[1]]
      authority <- parts[[length(parts)]]
    }
    base <- paste0(scheme, authority, tail)
  }
  kept_query <- if (is.na(query)) "" else keep_params(query)
  kept_fragment <- if (is.na(fragment)) {
    NA_character_
  } else if (grepl("=", fragment, fixed = TRUE)) {
    keep_params(fragment)
  } else {
    fragment
  }
  paste0(
    base,
    if (nzchar(kept_query)) paste0("?", kept_query) else "",
    if (!is.na(kept_fragment) && nzchar(kept_fragment)) paste0("#", kept_fragment) else ""
  )
}

# Recursively drop credential-named fields and sweep every string as a URL.
redact_config <- function(value, depth = 0L) {
  if (depth >= MAX_REDACT_DEPTH) return(NULL)
  if (is.character(value) && length(value) == 1L && !is.na(value)) {
    return(redact_url(value))
  }
  if (!is.list(value)) return(value)
  # Inlined GeoJSON is user data, not configuration; sweeping it would rewrite
  # every string property.
  if (is_scalar_string(value$type) &&
      value$type %in% c("FeatureCollection", "Feature", "GeometryCollection")) {
    return(value)
  }
  keys <- names(value)
  if (is.null(keys)) {
    return(lapply(value, redact_config, depth = depth + 1L))
  }
  keep <- !(normalize_credential_name(keys) %in% CREDENTIAL_FIELD_NAMES)
  value <- value[keep]
  for (key in names(value)) {
    value[[key]] <- redact_config(value[[key]], depth = depth + 1L)
  }
  value
}

#' Strip credentials from one layer
#'
#' @param layer A layer list, as returned inside a project's `layers`.
#' @return The layer with its credential-bearing configuration removed.
#' @examples
#' map <- geolibre() |>
#'   add_3d_tiles(
#'     "https://example.com/tileset.json",
#'     request_headers = list(Authorization = "Bearer secret")
#'   )
#' layer <- redact_layer(map$x$project$layers[[1]])
#' is.null(layer$source$requestHeaders)
#' @export
redact_layer <- function(layer) {
  if (!is.list(layer)) return(layer)
  for (field in LAYER_CREDENTIAL_FIELDS) {
    if (!is.null(layer[[field]])) layer[[field]] <- redact_config(layer[[field]])
  }
  layer
}

#' Strip credentials from a whole project
#'
#' Returns a project safe to publish, export, or hand to someone else: layer
#' request headers and signed URLs, basemap style keys, geocoding keys, stored
#' environment variables, and third-party plugin settings are all removed. The
#' first-party map controls (legend, colorbar, swipe) are kept, since a project
#' needs them to render as it was built.
#'
#' [save_project()] applies this by default.
#'
#' @param project A GeoLibre widget or a project list.
#' @return The project list with credentials removed.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39)
#' safe <- redact_credentials(map)
#' safe$name
#' @export
redact_credentials <- function(project) {
  project <- as_project_list(project)
  if (is_scalar_string(project$basemapStyleUrl)) {
    project$basemapStyleUrl <- redact_url(project$basemapStyleUrl)
  }
  if (is.list(project$preferences)) {
    project$preferences$environmentVariables <- empty_array()
    if (is.list(project$preferences$geocoding)) {
      project$preferences$geocoding$apiKeys <- empty_object()
      for (field in c("forwardEndpoint", "reverseEndpoint")) {
        if (is_scalar_string(project$preferences$geocoding[[field]])) {
          project$preferences$geocoding[[field]] <-
            redact_url(project$preferences$geocoding[[field]])
        }
      }
    }
  }
  if (is.list(project$layers)) {
    project$layers <- lapply(project$layers, redact_layer)
  }
  if (is.list(project$plugins)) {
    urls <- project$plugins$manifestUrls
    if (is.list(urls) || is.character(urls)) {
      project$plugins$manifestUrls <- as_json_array(
        vapply(as.list(urls), function(url) redact_url(url), character(1))
      )
    }
    settings <- project$plugins$settings
    project$plugins$settings <- if (is.list(settings)) {
      filter_plugin_settings(settings)
    } else {
      empty_object()
    }
  }
  if (!is.null(project$metadata)) {
    project$metadata <- redact_config(project$metadata)
  }
  project
}

filter_plugin_settings <- function(settings) {
  allowed <- publishable_plugin_settings()
  kept <- empty_object()
  for (plugin_id in names(settings)) {
    if (!plugin_id %in% names(allowed)) next
    keys <- allowed[[plugin_id]]
    value <- settings[[plugin_id]]
    if (is.null(keys)) {
      kept[[plugin_id]] <- redact_config(value)
    } else if (is.list(value)) {
      # An unexpected shape is dropped rather than passed through.
      subset <- value[intersect(names(value), keys)]
      if (length(subset)) kept[[plugin_id]] <- redact_config(subset)
    }
  }
  kept
}
