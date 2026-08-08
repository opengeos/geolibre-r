#' Read a GeoLibre project
#'
#' @param source Path to a `.geolibre.json` file or a JSON string.
#' @return A project list.
#' @export
load_project <- function(source) {
  if (!is.character(source) || length(source) != 1L) stop("`source` must be a path or JSON string.", call. = FALSE)
  project <- if (file.exists(source)) {
    jsonlite::read_json(source, simplifyVector = FALSE)
  } else {
    jsonlite::fromJSON(source, simplifyVector = FALSE)
  }
  normalize_project(project)
}

#' Save a GeoLibre project
#'
#' @param map A GeoLibre widget or project list.
#' @param path Output path, conventionally ending in `.geolibre.json`.
#' @return `path`, invisibly.
#' @export
save_project <- function(map, path) {
  project <- if (inherits(map, "geolibre")) widget_project(map) else normalize_project(map)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(project, path, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
  invisible(path)
}
