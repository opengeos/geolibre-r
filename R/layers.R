#' Add GeoJSON to a GeoLibre map
#'
#' @param map A GeoLibre widget.
#' @param data A GeoJSON list, JSON string, file path, or an `sf` object.
#' @param name Layer name.
#' @param style Named list of GeoLibre style overrides such as `fillColor`,
#'   `strokeColor`, and `strokeWidth`.
#' @param visible Whether the layer is initially visible.
#' @param opacity Layer opacity from zero to one.
#' @return The modified widget.
#' @export
add_geojson <- function(map, data, name = "GeoJSON", style = list(),
                        visible = TRUE, opacity = 1) {
  project <- widget_project(map)
  geojson <- as_geojson(data)
  layer <- list(
    id = random_id(), name = name, type = "geojson",
    visible = isTRUE(visible), opacity = validate_opacity(opacity),
    source = list(type = "geojson"), style = style,
    metadata = list(), geojson = geojson
  )
  project$layers <- append(project$layers, list(layer))
  set_widget_project(map, project)
}

#' Add an `sf` object to a GeoLibre map
#'
#' The object is transformed to EPSG:4326 before serialization.
#' @param map A GeoLibre widget.
#' @param data An `sf` or `sfc` object.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @export
add_sf <- function(map, data, name = deparse(substitute(data)), style = list(),
                   visible = TRUE, opacity = 1) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package `sf` is required by add_sf().", call. = FALSE)
  }
  if (!inherits(data, c("sf", "sfc"))) stop("`data` must be an sf or sfc object.", call. = FALSE)
  data <- sf::st_transform(sf::st_as_sf(data), 4326)
  add_geojson(map, data, name, style, visible, opacity)
}

#' Add a remote raster to a GeoLibre map
#'
#' @param map A GeoLibre widget.
#' @param url Public HTTP(S) URL of a Cloud Optimized GeoTIFF or GeoTIFF.
#' @param name Layer name.
#' @param bands Optional one-based band indices.
#' @param colormap Optional GeoLibre colormap name.
#' @param rescale Optional list of numeric `[min, max]` ranges.
#' @param style Named list of style overrides.
#' @param visible Whether the layer is visible.
#' @param opacity Layer opacity from zero to one.
#' @return The modified widget.
#' @export
add_raster <- function(map, url, name = "Raster", bands = NULL,
                       colormap = NULL, rescale = NULL, style = list(),
                       visible = TRUE, opacity = 1) {
  if (!is.character(url) || length(url) != 1L || !grepl("^https?://", url)) {
    stop("`url` must be a single public HTTP(S) URL.", call. = FALSE)
  }
  project <- widget_project(map)
  id <- random_id()
  raster_state <- Filter(Negate(is.null), list(
    bands = bands,
    mode = if (!is.null(bands)) if (length(bands) >= 3L) "rgb" else "single" else NULL,
    colormap = colormap,
    rescale = rescale
  ))
  layer <- list(
    id = id, name = name, type = "cog", visible = isTRUE(visible),
    opacity = validate_opacity(opacity), style = style,
    source = list(type = "raster", url = url), sourcePath = url,
    metadata = list(
      customLayerType = "raster", externalDeckLayer = TRUE,
      externalNativeLayer = TRUE, identifiable = FALSE,
      nativeLayerIds = list(id), panelCollapsed = TRUE,
      rasterOverlayMode = "interleaved", rasterSource = "url",
      rasterState = raster_state, sourceIds = list(),
      sourceKind = "maplibre-gl-raster"
    )
  )
  project$layers <- append(project$layers, list(layer))
  set_widget_project(map, project)
}

as_geojson <- function(data) {
  if (inherits(data, c("sf", "sfc"))) {
    if (!requireNamespace("sf", quietly = TRUE)) stop("Package `sf` is required.", call. = FALSE)
    data <- sf::st_transform(sf::st_as_sf(data), 4326)
    path <- tempfile(fileext = ".geojson")
    on.exit(unlink(path), add = TRUE)
    sf::st_write(data, path, driver = "GeoJSON", quiet = TRUE)
    return(jsonlite::read_json(path, simplifyVector = FALSE))
  }
  if (is.character(data) && length(data) == 1L) {
    text <- if (file.exists(data)) paste(readLines(data, warn = FALSE), collapse = "\n") else data
    return(jsonlite::fromJSON(text, simplifyVector = FALSE))
  }
  if (!is.list(data)) stop("`data` must be GeoJSON, a path, JSON, or an sf object.", call. = FALSE)
  data
}

validate_opacity <- function(value) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) || value < 0 || value > 1) {
    stop("`opacity` must be a number between 0 and 1.", call. = FALSE)
  }
  unname(value)
}
