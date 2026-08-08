# Reading, writing, and summarizing whole `.geolibre.json` projects.

# A project inlines its GeoJSON, so the ceiling here has to clear the per-layer
# inline limit with room for several more layers.
MAX_PROJECT_BYTES <- 256 * 1024^2

#' Read a GeoLibre project
#'
#' @param source Path to a `.geolibre.json` file or a JSON string.
#' @return A project list.
#' @seealso [save_project()], [describe_project()]
#' @examples
#' project <- load_project('{"version":"0.2.0","name":"Example","mapView":{}}')
#' stopifnot(project$name == "Example")
#'
#' # A saved project can be reopened as a widget.
#' path <- tempfile(fileext = ".geolibre.json")
#' save_project(geolibre() |> add_marker(-77, 39), path)
#' map <- geolibre(load_project(path))
#' @export
load_project <- function(source) {
  if (!is_scalar_string(source)) {
    stop_geolibre("`source` must be a path or JSON string.")
  }
  project <- if (file.exists(source)) {
    if (file.size(source) > MAX_PROJECT_BYTES) {
      stop_geolibre(
        "Project file exceeds the ", MAX_PROJECT_BYTES %/% 1024L^2L, " MB limit: ", source
      )
    }
    tryCatch(
      jsonlite::read_json(source, simplifyVector = FALSE),
      error = function(error) {
        stop_geolibre("Project file is not valid JSON: ", source, " (", conditionMessage(error), ")")
      }
    )
  } else {
    tryCatch(
      jsonlite::fromJSON(source, simplifyVector = FALSE),
      error = function(error) {
        stop_geolibre(
          "`source` is neither an existing file nor valid project JSON: ",
          conditionMessage(error)
        )
      }
    )
  }
  normalize_project(project)
}

#' Save a GeoLibre project
#'
#' @param map A GeoLibre widget or project list.
#' @param path Output path, conventionally ending in `.geolibre.json`.
#' @param keep_credentials Keep credential-bearing configuration such as layer
#'   request headers and signed URLs. Defaults to `FALSE`, so a saved project is
#'   safe to commit or share. See [redact_credentials()].
#' @return `path`, invisibly.
#' @seealso [load_project()], [redact_credentials()]
#' @examples
#' path <- tempfile(fileext = ".geolibre.json")
#' save_project(geolibre(), path)
#' project <- load_project(path)
#' stopifnot(project$name == "Untitled Project")
#' @export
save_project <- function(map, path, keep_credentials = FALSE) {
  if (!is_scalar_string(path) || !nzchar(path)) {
    stop_geolibre("`path` must be a single non-empty string.")
  }
  check_flag(keep_credentials, "keep_credentials")
  project <- as_project_list(map)
  if (!isTRUE(keep_credentials)) project <- redact_credentials(project)
  directory <- dirname(path)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  # Write beside the destination and move into place, so an interrupted write
  # cannot leave a half-written project where a complete one used to be.
  temporary <- tempfile(pattern = ".geolibre", tmpdir = directory, fileext = ".json")
  on.exit(unlink(temporary), add = TRUE)
  jsonlite::write_json(
    project, temporary,
    pretty = TRUE, auto_unbox = TRUE, null = "null", na = "null", digits = NA
  )
  if (!file.rename(temporary, path)) {
    # Renaming can fail across filesystems; fall back to a copy.
    if (!file.copy(temporary, path, overwrite = TRUE)) {
      stop_geolibre("Could not write the project to ", path, ".")
    }
  }
  invisible(path)
}

#' Read a project out of a widget
#'
#' @param map A GeoLibre widget or project list.
#' @param keep_credentials Keep credential-bearing configuration. Defaults to
#'   `FALSE`, so the returned project is safe to print or serialize.
#' @return The project as a list.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39, name = "Pin")
#' project <- get_project(map)
#' project$layers[[1]]$name
#' @export
get_project <- function(map, keep_credentials = FALSE) {
  check_flag(keep_credentials, "keep_credentials")
  project <- as_project_list(map)
  if (isTRUE(keep_credentials)) return(project)
  redact_credentials(project)
}

#' Summarize a GeoLibre project
#'
#' Reports the camera, basemap, layers, and active map controls. URLs come back
#' with their credentials stripped, since several basemap providers put an API key
#' in the style URL itself.
#'
#' @param project A GeoLibre widget or a project list.
#' @return A list with the project `name`, `version`, `mapView`,
#'   `basemapStyleUrl`, `layerCount`, a `layers` data frame, and the names of the
#'   active `mapControls`.
#' @seealso [get_layers()]
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   add_legend(legend = c(Pin = "#3b82f6"))
#' summary <- describe_project(map)
#' summary$layerCount
#' summary$mapControls
#' @export
describe_project <- function(project) {
  project <- as_project_list(project)
  controls <- character(0)
  plugins <- project$plugins
  if (is.list(plugins)) {
    settings <- plugins$settings
    active <- unlist(plugins$activePluginIds, use.names = FALSE)
    if (is.list(settings)) {
      # Swipe renders only while its plugin is active, so a settings blob left
      # behind by a deactivated control is not a live control. The legend and
      # colorbar are drawn from their settings alone.
      if (SWIPE_PLUGIN_ID %in% names(settings) && SWIPE_PLUGIN_ID %in% active) {
        controls <- c(controls, "swipe")
      }
      components <- settings[[COMPONENTS_PLUGIN_ID]]
      if (is.list(components)) {
        controls <- c(controls, intersect(c("legend", "colorbar"), names(components)))
      }
    }
  }
  list(
    name = project$name,
    version = project$version,
    mapView = project$mapView,
    basemapStyleUrl = if (is_scalar_string(project$basemapStyleUrl)) {
      redact_url(project$basemapStyleUrl)
    } else {
      project$basemapStyleUrl
    },
    layerCount = length(project_layers(project)),
    layers = get_layers(project),
    mapControls = controls
  )
}
