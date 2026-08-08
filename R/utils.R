# Internal helpers shared across the package: argument validation, identifiers,
# and the small JSON shape adjustments the GeoLibre project schema needs.

# An empty JSON object. jsonlite renders an unnamed empty list as `[]` and a
# named one as `{}`, and the app's schema expects objects for `styles`,
# `metadata`, `settings`, and friends.
empty_object <- function() {
  structure(list(), names = character(0))
}

# An empty JSON array.
empty_array <- function() {
  list()
}

# Force a value to serialize as a JSON array even when it holds one element.
# jsonlite's `auto_unbox = TRUE` collapses length-one atomic vectors to scalars,
# which would turn `tiles: ["url"]` into `tiles: "url"`.
as_json_array <- function(x) {
  if (is.null(x)) return(empty_array())
  if (is.list(x)) return(unname(x))
  as.list(unname(x))
}

stop_geolibre <- function(...) {
  stop(..., call. = FALSE)
}

is_scalar_string <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x)
}

is_scalar_number <- function(x) {
  is.numeric(x) && length(x) == 1L && is.finite(x)
}

is_scalar_flag <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}

check_string <- function(value, arg) {
  if (!is_scalar_string(value) || !nzchar(value)) {
    stop_geolibre("`", arg, "` must be a single non-empty string.")
  }
  value
}

check_number <- function(value, arg) {
  if (!is_scalar_number(value)) {
    stop_geolibre("`", arg, "` must be one finite numeric value.")
  }
  unname(value)
}

check_flag <- function(value, arg) {
  if (!is_scalar_flag(value)) {
    stop_geolibre("`", arg, "` must be TRUE or FALSE.")
  }
  value
}

check_integer <- function(value, arg, min = 1L) {
  if (!is_scalar_number(value) || value != floor(value) || value < min) {
    stop_geolibre("`", arg, "` must be a single integer of at least ", min, ".")
  }
  as.integer(value)
}

check_choice <- function(value, choices, arg) {
  if (!is_scalar_string(value) || !(value %in% choices)) {
    stop_geolibre(
      "`", arg, "` must be one of ", paste0("\"", choices, "\"", collapse = ", "), "."
    )
  }
  value
}

check_http_url <- function(value, arg) {
  if (!is_scalar_string(value) || !grepl("^https?://", value)) {
    stop_geolibre("`", arg, "` must be a single HTTP(S) URL.")
  }
  value
}

# A `[lng, lat]` pair.
check_lnglat <- function(value, arg = "center") {
  if (!is.numeric(value) || length(value) != 2L || any(!is.finite(value))) {
    stop_geolibre(
      "`", arg, "` must be c(longitude, latitude) with two finite numeric values."
    )
  }
  unname(as.numeric(value))
}

# A `[west, south, east, north]` bounding box.
check_bbox <- function(value, arg = "bbox") {
  if (!is.numeric(value) || length(value) != 4L || any(!is.finite(value))) {
    stop_geolibre("`", arg, "` must have four finite numeric values.")
  }
  unname(as.numeric(value))
}

clamp <- function(value, low, high) {
  min(high, max(low, value))
}

validate_opacity <- function(value) {
  if (!is_scalar_number(value) || value < 0 || value > 1) {
    stop_geolibre("`opacity` must be a number between 0 and 1.")
  }
  unname(value)
}

# Shallow-merge `overrides` into `base`, keeping `base`'s key order.
#
# This is deliberately not utils::modifyList(), which recurses into any value
# that is a list in both arguments. A style value such as `vectorStyleStops` is
# an *unnamed* list of stops, and recursing into it merges nothing (there are no
# names to match), silently keeping the base value.
merge_lists <- function(base, overrides) {
  if (!length(overrides)) return(base)
  for (key in names(overrides)) {
    # Single-bracket assignment from a one-element list, so an override whose
    # value is NULL sets the key to NULL rather than deleting it.
    if (key %in% names(base)) {
      base[match(key, names(base))] <- overrides[key]
    } else {
      base[key] <- overrides[key]
    }
  }
  base
}

# The package's own random number stream, kept separate from the caller's so
# generating layer ids neither perturbs a reproducible script nor repeats itself
# when the caller reseeds. Holds the stream's `.Random.seed` between calls.
id_stream <- new.env(parent = emptyenv())

# A random UUID v4 string, matching the layer ids the application and the Python
# API generate.
new_uuid <- function() {
  digits <- c(0:9, letters[1:6])
  had_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  caller_seed <- if (had_seed) {
    get(".Random.seed", envir = globalenv(), inherits = FALSE)
  }
  on.exit(
    {
      # Carry this stream forward, then hand the caller's back untouched.
      id_stream$seed <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
      if (had_seed) {
        assign(".Random.seed", caller_seed, envir = globalenv())
      } else {
        suppressWarnings(rm(".Random.seed", envir = globalenv()))
      }
    },
    add = TRUE
  )
  if (is.null(id_stream$seed)) {
    # Seed once per session from the clock and process id, which are independent
    # of the caller's stream, so ids differ between sessions.
    set.seed(as.integer((as.numeric(Sys.time()) * 1000 + Sys.getpid()) %% 2147483647))
  } else {
    assign(".Random.seed", id_stream$seed, envir = globalenv())
  }
  draw <- function(n) paste(sample(digits, n, replace = TRUE), collapse = "")
  paste(
    draw(8L), draw(4L), paste0("4", draw(3L)),
    paste0(sample(c("8", "9", "a", "b"), 1L), draw(3L)), draw(12L),
    sep = "-"
  )
}

require_suggested <- function(package, caller) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop_geolibre("Package `", package, "` is required by ", caller, ".")
  }
  invisible(TRUE)
}

# Merge the named arguments captured by `...` into an explicit `style` list.
# Mirrors the Python API, where style overrides arrive as keyword arguments.
merge_style <- function(style, dots) {
  if (!is.list(style)) stop_geolibre("`style` must be a named list.")
  if (length(style) && (is.null(names(style)) || any(!nzchar(names(style))))) {
    stop_geolibre("`style` must be a named list.")
  }
  if (!length(dots)) return(style)
  if (is.null(names(dots)) || any(!nzchar(names(dots)))) {
    stop_geolibre("Style overrides passed through `...` must all be named.")
  }
  style[names(dots)] <- dots
  style
}

validate_layer_options <- function(name, style, visible) {
  check_string(name, "name")
  if (!is.list(style)) stop_geolibre("`style` must be a named list.")
  if (length(style) && (is.null(names(style)) || any(!nzchar(names(style))))) {
    stop_geolibre("`style` must be a named list.")
  }
  check_flag(visible, "visible")
  invisible(TRUE)
}

# Append query parameters the way the application's `appendQuery` helper does,
# so a service URL built here is byte-identical to one built in the app. The
# `{bbox-epsg-3857}` placeholder is preserved so the raster source can
# substitute per-tile bounds at request time.
append_query <- function(endpoint, params) {
  parts <- strsplit(endpoint, "#", fixed = TRUE)[[1]]
  base <- if (length(parts)) parts[[1]] else ""
  fragment <- if (length(parts) > 1L) paste0("#", paste(parts[-1], collapse = "#")) else ""
  separator <- if (grepl("?", base, fixed = TRUE)) {
    if (grepl("[?&]$", base)) "" else "&"
  } else {
    "?"
  }
  encode <- function(value) {
    if (identical(value, "{bbox-epsg-3857}")) return(value)
    utils::URLencode(value, reserved = TRUE)
  }
  query <- paste(
    vapply(
      names(params),
      function(key) paste0(encode(key), "=", encode(as.character(params[[key]]))),
      character(1)
    ),
    collapse = "&"
  )
  paste0(base, separator, query, fragment)
}
