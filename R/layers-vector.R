# Vector layer constructors. Each returns the modified widget so calls compose
# with the pipe.

# Apply the shared `visible` / `opacity` layer options to a built layer.
finish_layer <- function(layer, visible, opacity) {
  layer$visible <- check_flag(visible, "visible")
  layer$opacity <- validate_opacity(opacity)
  layer
}

#' Add GeoJSON to a GeoLibre map
#'
#' @param map A GeoLibre widget.
#' @param data GeoJSON as a parsed list (a `FeatureCollection`, `Feature`, or
#'   bare geometry), a JSON string, a file path, an HTTP(S) URL, or an `sf`
#'   object. A URL or file is read and inlined into the project, up to a 50 MB
#'   limit; for larger datasets prefer [add_vector()], which lets the browser
#'   stream the source.
#' @param name Layer name.
#' @param style Named list of GeoLibre style overrides such as `fillColor`,
#'   `strokeColor`, and `strokeWidth`.
#' @param visible Whether the layer is initially visible.
#' @param opacity Layer opacity from zero to one.
#' @param ... Additional style overrides given as named arguments, merged into
#'   `style`. `add_geojson(map, data, fillColor = "red")` and
#'   `add_geojson(map, data, style = list(fillColor = "red"))` are equivalent.
#' @return The modified widget.
#' @seealso [add_sf()], [add_choropleth()], [add_vector()]
#' @examples
#' point <- list(
#'   type = "Feature",
#'   properties = list(name = "Washington, DC"),
#'   geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
#' )
#' map <- geolibre() |> add_geojson(point, name = "Places", fillColor = "#dc2626")
#' stopifnot(length(map$x$project$layers) == 1L)
#' @export
add_geojson <- function(map, data, name = "GeoJSON", style = list(),
                        visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  source_url <- if (is_http_url(data)) data else NULL
  collection <- as_featurecollection(data)
  append_layer(
    map,
    finish_layer(
      geojson_layer(name, collection, source_url = source_url, style = style),
      visible, opacity
    )
  )
}

#' Add an `sf` object to a GeoLibre map
#'
#' The object is transformed to EPSG:4326 before serialization. An object with no
#' CRS is taken to be in longitude/latitude order already, since that is what
#' GeoJSON means.
#'
#' @param map A GeoLibre widget.
#' @param data An `sf`, `sfc`, or `sfg` object.
#' @param name Layer name. Defaults to the expression passed as `data`.
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
add_sf <- function(map, data, name = NULL, style = list(),
                   visible = TRUE, opacity = 1, ...) {
  if (is.null(name)) {
    # A multi-line or very long expression makes a poor layer name, so fall back
    # to a generic one rather than passing deparse()'s several elements along.
    deparsed <- paste(deparse(substitute(data)), collapse = " ")
    name <- if (nchar(deparsed) > 60L || !nzchar(trimws(deparsed))) "sf" else deparsed
  }
  require_suggested("sf", "add_sf()")
  if (!inherits(data, c("sf", "sfc", "sfg"))) {
    stop_geolibre("`data` must be an sf, sfc, or sfg object.")
  }
  add_geojson(map, data, name, style, visible, opacity, ...)
}

#' Add a data-driven choropleth layer
#'
#' Classifies `column` into `class_count` numeric ranges and colors each range
#' from `colormap`, producing the same graduated symbology the application's
#' Style panel builds from the interface.
#'
#' @inheritParams add_geojson
#' @param column Name of the numeric feature property to classify.
#' @param class_count Number of classes, clamped to between 2 and 12.
#' @param colormap A color ramp name from [color_ramp_names()].
#' @param scheme Classification scheme, `"equal-interval"` or `"quantile"`.
#' @return The modified widget.
#' @seealso [classify_layer()] to symbolize a layer that is already on the map.
#' @examples
#' counties <- list(
#'   type = "FeatureCollection",
#'   features = list(
#'     list(
#'       type = "Feature", properties = list(pop = 100),
#'       geometry = list(type = "Point", coordinates = c(-77, 39))
#'     ),
#'     list(
#'       type = "Feature", properties = list(pop = 900),
#'       geometry = list(type = "Point", coordinates = c(-76, 40))
#'     )
#'   )
#' )
#' map <- geolibre() |>
#'   add_choropleth(counties, column = "pop", colormap = "blues", class_count = 3)
#' stopifnot(map$x$project$layers[[1]]$style$vectorStyleMode == "graduated")
#' @export
add_choropleth <- function(map, data, column, name = "Choropleth",
                           class_count = 5, colormap = "viridis",
                           scheme = c("equal-interval", "quantile"),
                           style = list(), visible = TRUE, opacity = 1, ...) {
  check_string(column, "column")
  scheme <- check_choice(match.arg(scheme), CLASSIFICATION_SCHEMES, "scheme")
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  source_url <- if (is_http_url(data)) data else NULL
  collection <- as_featurecollection(data)
  values <- feature_column(collection$features, column)
  if (all(vapply(values, is.null, logical(1)))) {
    stop_geolibre("Column \"", column, "\" not found in any feature's properties.")
  }
  choropleth <- build_choropleth_style(
    values, column,
    class_count = class_count, colormap = colormap, scheme = scheme
  )
  # Caller overrides win over the computed symbology.
  append_layer(
    map,
    finish_layer(
      geojson_layer(
        name, collection,
        source_url = source_url,
        style = merge_lists(choropleth, style)
      ),
      visible, opacity
    )
  )
}

#' Add data, optionally symbolized by a column
#'
#' With `column` supplied this is [add_choropleth()]; without it, [add_geojson()].
#' Provided for parity with the Python API.
#'
#' @inheritParams add_geojson
#' @param column Optional numeric property to drive graduated symbology.
#' @param ... Forwarded to [add_choropleth()] or [add_geojson()].
#' @return The modified widget.
#' @examples
#' point <- list(type = "Point", coordinates = c(-77, 39))
#' map <- geolibre() |> add_data(point, name = "Point")
#' @export
add_data <- function(map, data, column = NULL, name = "Data", ...) {
  if (is.null(column)) {
    return(add_geojson(map, data, name = name, ...))
  }
  add_choropleth(map, data, column = column, name = name, ...)
}

#' Add a single point marker
#'
#' @param map A GeoLibre widget.
#' @param lng Marker longitude.
#' @param lat Marker latitude.
#' @param name Layer name.
#' @param properties Optional named list of feature properties, shown when the
#'   point is clicked.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77.0369, 38.9072, name = "DC", circleRadius = 10)
#' @export
add_marker <- function(map, lng, lat, name = "Marker", properties = NULL,
                       style = list(), visible = TRUE, opacity = 1, ...) {
  check_number(lng, "lng")
  check_number(lat, "lat")
  collection <- list(
    type = "FeatureCollection",
    features = list(point_feature(lng, lat, properties))
  )
  add_markers(map, collection, name, style, visible, opacity, ...)
}

#' Add point markers
#'
#' @param map A GeoLibre widget.
#' @param points Points as a two-column matrix or a data frame of coordinates, a
#'   list of `c(longitude, latitude)` pairs or named
#'   `list(lng = , lat = , ...)` entries, a point GeoJSON source, or an `sf`
#'   object of points.
#' @param name Layer name.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @seealso [add_circle_markers()], [add_marker_cluster()], [add_heatmap()]
#' @examples
#' map <- geolibre() |>
#'   add_markers(list(c(-77.0369, 38.9072), c(-74.006, 40.7128)), name = "Cities")
#' stopifnot(length(map$x$project$layers[[1]]$geojson$features) == 2L)
#' @export
add_markers <- function(map, points, name = "Markers", style = list(),
                        visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  collection <- points_to_featurecollection(points)
  append_layer(
    map,
    finish_layer(geojson_layer(name, collection, style = style), visible, opacity)
  )
}

#' Add circle markers
#'
#' [add_markers()] with the circle radius surfaced as a named argument.
#'
#' @inheritParams add_markers
#' @param radius Optional circle radius in pixels.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_circle_markers(list(c(-77, 39)), radius = 12, fillColor = "#16a34a")
#' @export
add_circle_markers <- function(map, points, name = "Circle Markers", radius = NULL,
                               style = list(), visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  if (!is.null(radius) && is.null(style$circleRadius)) {
    style$circleRadius <- check_number(radius, "radius")
  }
  add_markers(map, points, name, style, visible, opacity)
}

#' Add clustered point markers
#'
#' Builds a point layer with the cluster renderer enabled, so nearby points
#' collapse into count bubbles that split apart as the map zooms in.
#'
#' @inheritParams add_markers
#' @param cluster_radius Cluster radius in pixels.
#' @param cluster_max_zoom Zoom level beyond which points are no longer clustered.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker_cluster(list(c(-77, 39), c(-77.1, 39.1)), cluster_radius = 60)
#' stopifnot(map$x$project$layers[[1]]$style$pointRenderer == "cluster")
#' @export
add_marker_cluster <- function(map, points, name = "Marker Cluster",
                               cluster_radius = 50, cluster_max_zoom = 14,
                               style = list(), visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  if (is.null(style$pointRenderer)) style$pointRenderer <- "cluster"
  if (is.null(style$clusterRadius)) {
    style$clusterRadius <- check_integer(cluster_radius, "cluster_radius", min = 0L)
  }
  if (is.null(style$clusterMaxZoom)) {
    style$clusterMaxZoom <- check_integer(cluster_max_zoom, "cluster_max_zoom", min = 0L)
  }
  add_markers(map, points, name, style, visible, opacity)
}

#' Add a point density heatmap
#'
#' @inheritParams add_markers
#' @param radius Heatmap kernel radius in pixels.
#' @param intensity Heatmap intensity multiplier.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_heatmap(list(c(-77, 39), c(-77.05, 39.02)), radius = 40)
#' stopifnot(map$x$project$layers[[1]]$style$pointRenderer == "heatmap")
#' @export
add_heatmap <- function(map, points, name = "Heatmap", radius = 30, intensity = 1,
                        style = list(), visible = TRUE, opacity = 1, ...) {
  radius <- check_number(radius, "radius")
  intensity <- check_number(intensity, "intensity")
  if (radius <= 0) stop_geolibre("`radius` must be greater than zero.")
  if (intensity < 0) stop_geolibre("`intensity` must not be negative.")
  style <- merge_style(style, list(...))
  if (is.null(style$pointRenderer)) style$pointRenderer <- "heatmap"
  if (is.null(style$heatmapRadius)) style$heatmapRadius <- radius
  if (is.null(style$heatmapIntensity)) style$heatmapIntensity <- intensity
  add_markers(map, points, name, style, visible, opacity)
}

#' Add points from tabular longitude and latitude columns
#'
#' @param map A GeoLibre widget.
#' @param data A data frame, a CSV file path, a CSV URL, CSV text, or a list of
#'   row lists.
#' @param x Name of the longitude column.
#' @param y Name of the latitude column.
#' @param name Layer name.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' cities <- data.frame(
#'   name = c("Washington", "New York"),
#'   longitude = c(-77.0369, -74.006),
#'   latitude = c(38.9072, 40.7128)
#' )
#' map <- geolibre() |> add_xy_data(cities, name = "Cities")
#' stopifnot(length(map$x$project$layers[[1]]$geojson$features) == 2L)
#' @export
add_xy_data <- function(map, data, x = "longitude", y = "latitude", name = "XY Data",
                        style = list(), visible = TRUE, opacity = 1, ...) {
  check_string(x, "x")
  check_string(y, "y")
  if (is.data.frame(data) && has_atomic_vector_columns(data)) {
    features <- data_frame_point_features(data, x, y)
    return(add_markers(
      map, list(type = "FeatureCollection", features = features),
      name, style, visible, opacity, ...
    ))
  }
  records <- tabular_records(data)
  # Build the features here rather than handing named entries to the marker
  # coercion: that path strips every coordinate alias it recognizes, which would
  # silently drop a column legitimately named x, y, lon, or longitude when it is
  # not the one chosen as a coordinate.
  features <- lapply(seq_along(records), function(index) {
    row <- records[[index]]
    if (!(x %in% names(row)) || !(y %in% names(row))) {
      stop_geolibre(
        "Row ", index, " is missing coordinate columns \"", x, "\" and/or \"", y, "\"."
      )
    }
    coordinates <- parse_point_coordinates(row[[x]], row[[y]], index)
    point_feature(
      coordinates[[1]], coordinates[[2]],
      row[setdiff(names(row), c(x, y))]
    )
  })
  add_markers(
    map, list(type = "FeatureCollection", features = features),
    name, style, visible, opacity, ...
  )
}

#' Add a CSV of point coordinates
#'
#' [add_xy_data()] with a CSV-oriented default layer name.
#'
#' @inheritParams add_xy_data
#' @return The modified widget.
#' @examples
#' text <- "name,longitude,latitude\nDC,-77.0369,38.9072"
#' map <- geolibre() |> add_csv(text)
#' @export
add_csv <- function(map, data, x = "longitude", y = "latitude", name = "CSV",
                    style = list(), visible = TRUE, opacity = 1, ...) {
  add_xy_data(map, data, x, y, name, style, visible, opacity, ...)
}

#' Add a vector dataset from a URL or local file
#'
#' A remote URL is handed to the application's in-browser vector control, so any
#' format it reads (GeoParquet, FlatGeobuf, zipped Shapefile, GeoPackage,
#' GeoJSON, KML, ...) streams without being inlined in the project. A local file
#' is read with `sf` and inlined as GeoJSON, since the browser cannot reach a
#' file on this machine.
#'
#' @param map A GeoLibre widget.
#' @param data A dataset URL, a local file path, or an `sf` object.
#' @param name Layer name.
#' @param render_mode `"geojson"` to load into a GeoJSON source, or `"tiles"` to
#'   stream as vector tiles. Remote URLs only.
#' @param data_format Optional format hint for remote URLs, for example
#'   `"parquet"` or `"flatgeobuf"`. The control auto-detects when omitted.
#' @param source_layer Optional layer or table name inside a multi-layer
#'   container such as a GeoPackage.
#' @param picker Optional toggle for the control's feature-inspection popup.
#' @param ingest_mode Optional ingest strategy, `"table"` or `"stream"`.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_vector("https://example.com/data.parquet", name = "Parcels")
#' stopifnot(map$x$project$layers[[1]]$metadata$sourceKind == "maplibre-gl-vector")
#' @export
add_vector <- function(map, data, name = "Vector", render_mode = c("geojson", "tiles"),
                       data_format = NULL, source_layer = NULL, picker = NULL,
                       ingest_mode = NULL, style = list(), visible = TRUE,
                       opacity = 1, ...) {
  render_mode <- match.arg(render_mode)
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  if (is_http_url(data)) {
    return(append_layer(
      map,
      finish_layer(
        vector_layer(
          name, data,
          render_mode = render_mode, data_format = data_format,
          source_layer = source_layer, picker = picker,
          ingest_mode = ingest_mode, style = style
        ),
        visible, opacity
      )
    ))
  }
  if (inherits(data, c("sf", "sfc", "sfg"))) {
    return(add_geojson(map, data, name, style, visible, opacity))
  }
  if (!identical(render_mode, "geojson")) {
    warning(
      "`render_mode` is ignored for local files; it only applies to remote URLs ",
      "handled by the in-browser vector control.",
      call. = FALSE
    )
  }
  collection <- read_local_vector(data, source_layer = source_layer)
  append_layer(
    map,
    finish_layer(geojson_layer(name, collection, style = style), visible, opacity)
  )
}

#' Add a GeoParquet layer
#'
#' @inheritParams add_vector
#' @return The modified widget.
#' @examples
#' geolibre() |> add_geoparquet("https://example.com/data.parquet")
#' @export
add_geoparquet <- function(map, data, name = "GeoParquet", ...) {
  add_vector(map, data, name = name, data_format = "parquet", ...)
}

#' Add a FlatGeobuf layer
#'
#' @inheritParams add_vector
#' @return The modified widget.
#' @examples
#' geolibre() |> add_flatgeobuf("https://example.com/data.fgb")
#' @export
add_flatgeobuf <- function(map, data, name = "FlatGeobuf", ...) {
  add_vector(map, data, name = name, data_format = "flatgeobuf", ...)
}

#' Add a Shapefile layer
#'
#' @inheritParams add_vector
#' @param data A zipped Shapefile URL, or a local `.shp` path read with `sf`.
#' @return The modified widget.
#' @examples
#' geolibre() |> add_shp("https://example.com/data.zip")
#' @export
add_shp <- function(map, data, name = "Shapefile", ...) {
  add_vector(map, data, name = name, data_format = "shp", ...)
}

#' Add a KML or KMZ layer
#'
#' @inheritParams add_vector
#' @return The modified widget.
#' @examples
#' geolibre() |> add_kml("https://example.com/places.kml")
#' @export
add_kml <- function(map, data, name = "KML", ...) {
  add_vector(map, data, name = name, data_format = "kml", ...)
}

#' Add a GeoPackage layer
#'
#' @inheritParams add_vector
#' @param layer Optional table name inside the GeoPackage.
#' @return The modified widget.
#' @examples
#' geolibre() |> add_gpkg("https://example.com/data.gpkg", layer = "parcels")
#' @export
add_gpkg <- function(map, data, name = "GeoPackage", layer = NULL, ...) {
  add_vector(map, data, name = name, data_format = "gpkg", source_layer = layer, ...)
}

# Read one feature property across a FeatureCollection's features, as a list with
# NULL where the property is absent.
feature_column <- function(features, column) {
  lapply(features, function(feature) {
    properties <- if (is.list(feature)) feature$properties else NULL
    if (!is.list(properties)) NULL else properties[[column]]
  })
}
