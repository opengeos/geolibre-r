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
#' @examples
#' point <- list(
#'   type = "Feature",
#'   properties = list(name = "Washington, DC"),
#'   geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
#' )
#' map <- geolibre() |> add_geojson(point, name = "Places")
#' stopifnot(length(map$x$project$layers) == 1L)
#' @export
add_geojson <- function(map, data, name = "GeoJSON", style = list(),
                        visible = TRUE, opacity = 1) {
  validate_layer_options(name, style, visible)
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
#' @examples
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   point <- sf::st_sf(
#'     name = "Washington, DC",
#'     geometry = sf::st_sfc(sf::st_point(c(-77.0369, 38.9072)), crs = 4326)
#'   )
#'   map <- geolibre() |> add_sf(point, name = "Places")
#' }
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
#' @examples
#' map <- geolibre() |>
#'   add_raster("https://example.com/image.tif", bands = c(1, 2, 3))
#' stopifnot(map$x$project$layers[[1]]$type == "cog")
#' @export
add_raster <- function(map, url, name = "Raster", bands = NULL,
                       colormap = NULL, rescale = NULL, style = list(),
                       visible = TRUE, opacity = 1) {
  validate_layer_options(name, style, visible)
  if (!is.character(url) || length(url) != 1L || is.na(url) || !grepl("^https?://", url)) {
    stop("`url` must be a single public HTTP(S) URL.", call. = FALSE)
  }
  if (!is.null(colormap) &&
      (!is.character(colormap) || length(colormap) != 1L || is.na(colormap))) {
    stop("`colormap` must be NULL or a single string.", call. = FALSE)
  }
  if (!is.null(bands) &&
      (!is.numeric(bands) || !length(bands) || any(!is.finite(bands)) ||
       any(bands <= 0) || any(bands != floor(bands)))) {
    stop("`bands` must contain positive integer indices.", call. = FALSE)
  }
  valid_rescale <- is.null(rescale) ||
    (is.list(rescale) && all(vapply(
      rescale,
      function(range) {
        is.numeric(range) && length(range) == 2L &&
          all(is.finite(range)) && range[[1]] <= range[[2]]
      },
      logical(1)
    )))
  if (!valid_rescale) {
    stop("Each `rescale` range must be two finite numbers ordered min <= max.", call. = FALSE)
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
    data <- jsonlite::read_json(path, simplifyVector = FALSE)
  }
  if (is.character(data) && length(data) == 1L) {
    text <- if (file.exists(data)) paste(readLines(data, warn = FALSE), collapse = "\n") else data
    data <- tryCatch(
      jsonlite::fromJSON(text, simplifyVector = FALSE),
      error = function(error) stop("`data` is not valid GeoJSON: ", conditionMessage(error), call. = FALSE)
    )
  }
  if (!is.list(data)) stop("`data` must be GeoJSON, a path, JSON, or an sf object.", call. = FALSE)
  type <- data$type
  if (!is.character(type) || length(type) != 1L) {
    stop("GeoJSON must have a single string `type`.", call. = FALSE)
  }
  if (identical(type, "FeatureCollection")) {
    if (is.null(data$features)) data$features <- list()
    if (!is.list(data$features)) stop("A GeoJSON FeatureCollection must contain a `features` list.", call. = FALSE)
    return(data)
  }
  if (identical(type, "Feature")) {
    return(list(type = "FeatureCollection", features = list(data)))
  }
  geometry_types <- c(
    "Point", "MultiPoint", "LineString", "MultiLineString",
    "Polygon", "MultiPolygon", "GeometryCollection"
  )
  if (type %in% geometry_types) {
    return(list(
      type = "FeatureCollection",
      features = list(list(type = "Feature", properties = list(), geometry = data))
    ))
  }
  stop("Unsupported GeoJSON type: ", type, call. = FALSE)
}

validate_opacity <- function(value) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) || value < 0 || value > 1) {
    stop("`opacity` must be a number between 0 and 1.", call. = FALSE)
  }
  unname(value)
}

validate_layer_options <- function(name, style, visible) {
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)) {
    stop("`name` must be a single non-empty string.", call. = FALSE)
  }
  if (!is.list(style)) stop("`style` must be a named list.", call. = FALSE)
  if (length(style) && (is.null(names(style)) || any(!nzchar(names(style))))) {
    stop("`style` must be a named list.", call. = FALSE)
  }
  if (!is.logical(visible) || length(visible) != 1L || is.na(visible)) {
    stop("`visible` must be TRUE or FALSE.", call. = FALSE)
  }
  invisible(TRUE)
}
