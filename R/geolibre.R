#' Create a GeoLibre widget
#'
#' @param project A GeoLibre project list, a path to a `.geolibre.json` file,
#'   or `NULL` for a new project.
#' @param width,height Widget dimensions passed to [htmlwidgets::createWidget()].
#' @param app_url URL of a GeoLibre web deployment. It must support the
#'   `?embed=1` project bridge.
#' @param map_only Hide the application chrome and show only the map.
#' @param elementId Optional widget element ID.
#' @details The default hosted application requires internet access when the
#'   widget is displayed. Package installation, project construction, and file
#'   operations do not contact it. Set `app_url` or the `geolibre.app_url`
#'   option to use a self-hosted deployment.
#' @return An `htmlwidget` that can be modified with `add_*()` functions.
#' @examples
#' map <- geolibre(map_only = TRUE)
#' stopifnot(inherits(map, "geolibre"))
#' @export
geolibre <- function(project = NULL, width = NULL, height = NULL,
                     app_url = getOption("geolibre.app_url", "https://web.geolibre.app/"),
                     map_only = FALSE, elementId = NULL) {
  if (!is.character(app_url) || length(app_url) != 1L || is.na(app_url) ||
      !grepl("^https?://", app_url)) {
    stop("`app_url` must be a single HTTP(S) URL.", call. = FALSE)
  }
  project <- normalize_project(project)
  htmlwidgets::createWidget(
    name = "geolibre",
    x = list(project = project, appUrl = app_url, mapOnly = isTRUE(map_only)),
    width = width,
    height = height,
    package = "geolibre",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultHeight = 700,
      padding = 0,
      browser.fill = TRUE,
      viewer.fill = TRUE,
      browser.padding = 0,
      viewer.padding = 0
    )
  )
}

new_project <- function(name = "Untitled Project") {
  list(
    version = "0.2.0",
    name = name,
    mapView = list(center = c(0, 20), zoom = 2, bearing = 0, pitch = 0),
    basemapStyleUrl = "https://tiles.openfreemap.org/styles/liberty",
    basemapVisible = TRUE,
    basemapOpacity = 1,
    layers = list(),
    styles = list(),
    preferences = list(),
    metadata = list()
  )
}

normalize_project <- function(project) {
  if (is.null(project)) return(new_project())
  if (is.character(project) && length(project) == 1L) return(load_project(project))
  if (!is.list(project)) stop("`project` must be a list, JSON string, or file path.", call. = FALSE)
  required <- c("version", "name", "mapView")
  missing <- setdiff(required, names(project))
  if (length(missing)) stop("Invalid project; missing: ", paste(missing, collapse = ", "), call. = FALSE)
  if (!is.character(project$version) || length(project$version) != 1L || is.na(project$version)) {
    stop("Invalid project; `version` must be a single string.", call. = FALSE)
  }
  if (!is.character(project$name) || length(project$name) != 1L || is.na(project$name)) {
    stop("Invalid project; `name` must be a single string.", call. = FALSE)
  }
  if (!is.list(project$mapView)) stop("Invalid project; `mapView` must be a list.", call. = FALSE)
  if (is.null(project$layers)) project$layers <- list()
  if (!is.list(project$layers)) stop("Invalid project; `layers` must be a list.", call. = FALSE)
  project
}

widget_project <- function(map) {
  if (!inherits(map, "geolibre")) stop("`map` must be a GeoLibre widget.", call. = FALSE)
  map$x$project
}

set_widget_project <- function(map, project) {
  map$x$project <- project
  map
}

random_id <- function(prefix = "layer") {
  chars <- c(letters, 0:9)
  paste0(prefix, "-", paste(sample(chars, 16L, replace = TRUE), collapse = ""))
}
