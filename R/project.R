#' Read a GeoLibre project
#'
#' @param source Path to a `.geolibre.json` file or a JSON string.
#' @return A project list.
#' @examples
#' project <- load_project('{"version":"0.2.0","name":"Example","mapView":{}}')
#' stopifnot(project$name == "Example")
#' @export
load_project <- function(source) {
  if (!is.character(source) || length(source) != 1L) stop("`source` must be a path or JSON string.", call. = FALSE)
  project <- if (file.exists(source)) {
    jsonlite::read_json(source, simplifyVector = FALSE)
  } else {
    tryCatch(
      jsonlite::fromJSON(source, simplifyVector = FALSE),
      error = function(error) {
        stop("`source` is neither an existing file nor valid project JSON: ",
             conditionMessage(error), call. = FALSE)
      }
    )
  }
  normalize_project(project)
}

#' Save a GeoLibre project
#'
#' @param map A GeoLibre widget or project list.
#' @param path Output path, conventionally ending in `.geolibre.json`.
#' @return `path`, invisibly.
#' @examples
#' path <- tempfile(fileext = ".geolibre.json")
#' save_project(geolibre(), path)
#' project <- load_project(path)
#' stopifnot(project$name == "Untitled Project")
#' @export
save_project <- function(map, path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`path` must be a single non-empty string.", call. = FALSE)
  }
  project <- if (inherits(map, "geolibre")) widget_project(map) else normalize_project(map)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(project, path, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
  invisible(path)
}
