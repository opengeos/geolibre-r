# Raster, tile, and OGC service layer constructors.

validate_bands <- function(bands) {
  if (is.null(bands)) return(NULL)
  if (!is.numeric(bands) || !length(bands) || any(!is.finite(bands)) ||
      any(bands <= 0) || any(bands != floor(bands))) {
    stop_geolibre("`bands` must contain positive integer indices.")
  }
  as.integer(unname(bands))
}

validate_rescale <- function(rescale) {
  if (is.null(rescale)) return(NULL)
  if (is.numeric(rescale) && length(rescale) == 2L) rescale <- list(rescale)
  valid <- is.list(rescale) && length(rescale) && all(vapply(
    rescale,
    function(range) {
      is.numeric(range) && length(range) == 2L && all(is.finite(range)) &&
        range[[1]] <= range[[2]]
    },
    logical(1)
  ))
  if (!valid) {
    stop_geolibre("Each `rescale` range must be two finite numbers ordered min <= max.")
  }
  lapply(rescale, function(range) unname(as.numeric(range)))
}

validate_colormap <- function(colormap) {
  if (is.null(colormap)) return(NULL)
  if (!is_scalar_string(colormap)) {
    stop_geolibre("`colormap` must be NULL or a single string.")
  }
  colormap
}

#' Add a Cloud Optimized GeoTIFF layer
#'
#' @param map A GeoLibre widget.
#' @param url Public HTTP(S) URL of a Cloud Optimized GeoTIFF or GeoTIFF.
#' @param name Layer name.
#' @param bands Optional one-based band indices. Three or more bands render as
#'   RGB; one renders as a single band, which `colormap` then colors.
#' @param colormap Optional GeoLibre colormap name for single-band rendering.
#' @param rescale Optional list of numeric `c(min, max)` ranges, one per rendered
#'   band. A single `c(min, max)` pair is accepted for the one-band case.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @seealso [add_raster()], [add_tile_layer()], [add_colorbar()]
#' @examples
#' map <- geolibre() |>
#'   add_cog("https://example.com/image.tif", bands = c(1, 2, 3))
#' stopifnot(map$x$project$layers[[1]]$type == "cog")
#' @export
add_cog <- function(map, url, name = "COG", bands = NULL, colormap = NULL,
                    rescale = NULL, style = list(), visible = TRUE,
                    opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  append_layer(
    map,
    finish_layer(
      cog_layer(
        name, url,
        bands = validate_bands(bands),
        colormap = validate_colormap(colormap),
        rescale = validate_rescale(rescale),
        style = style
      ),
      visible, opacity
    )
  )
}

#' Add a remote raster to a GeoLibre map
#'
#' [add_cog()] with a generic default layer name.
#'
#' @inheritParams add_cog
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_raster("https://example.com/image.tif", bands = c(1, 2, 3))
#' stopifnot(map$x$project$layers[[1]]$type == "cog")
#' @export
add_raster <- function(map, url, name = "Raster", bands = NULL, colormap = NULL,
                       rescale = NULL, style = list(), visible = TRUE,
                       opacity = 1, ...) {
  add_cog(map, url, name, bands, colormap, rescale, style, visible, opacity, ...)
}

#' Add an XYZ raster tile layer
#'
#' @param map A GeoLibre widget.
#' @param url An XYZ tile URL template containing `{z}`, `{x}`, and `{y}`.
#' @param name Layer name.
#' @param tile_size Tile size in pixels, typically 256.
#' @param attribution Optional attribution string.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_tile_layer(
#'     "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
#'     name = "OpenStreetMap",
#'     attribution = "OpenStreetMap contributors"
#'   )
#' stopifnot(map$x$project$layers[[1]]$type == "xyz")
#' @export
add_tile_layer <- function(map, url, name = "Tile Layer", tile_size = 256,
                           attribution = NULL, style = list(), visible = TRUE,
                           opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  tile_size <- check_integer(tile_size, "tile_size")
  if (!is.null(attribution)) check_string(attribution, "attribution")
  append_layer(
    map,
    finish_layer(
      tile_layer(name, url, tile_size = tile_size, attribution = attribution, style = style),
      visible, opacity
    )
  )
}

#' Add a WMS layer
#'
#' The layer is rendered as tiled raster from WMS `GetMap` requests, built
#' exactly as the application's Add Data dialog builds them.
#'
#' @param map A GeoLibre widget.
#' @param endpoint WMS service endpoint, the `GetMap` base URL.
#' @param layers Comma-separated WMS layer name(s).
#' @param name Layer name.
#' @param styles Comma-separated WMS style name(s); empty for the server default.
#' @param image_format WMS image format, for example `"image/png"`.
#' @param transparent Whether to request transparent tiles.
#' @param tile_size Tile size in pixels.
#' @param version WMS protocol version, `"1.1.1"` or `"1.3.0"`. Version 1.3.0
#'   sends `CRS` instead of `SRS`; some servers accept only one version.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_wms(
#'     "https://example.com/geoserver/wms",
#'     layers = "topp:states",
#'     name = "States"
#'   )
#' stopifnot(map$x$project$layers[[1]]$type == "wms")
#' @export
add_wms <- function(map, endpoint, layers, name = "WMS Layer", styles = "",
                    image_format = "image/png", transparent = TRUE, tile_size = 256,
                    version = "1.1.1", style = list(), visible = TRUE,
                    opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(endpoint, "endpoint")
  check_string(layers, "layers")
  if (!is_scalar_string(styles)) stop_geolibre("`styles` must be a single string.")
  check_string(image_format, "image_format")
  check_flag(transparent, "transparent")
  append_layer(
    map,
    finish_layer(
      wms_layer(
        name, endpoint, layers,
        styles = styles, image_format = image_format, transparent = transparent,
        tile_size = check_integer(tile_size, "tile_size"), version = version,
        style = style
      ),
      visible, opacity
    )
  )
}

#' Add a WMTS layer
#'
#' @param map A GeoLibre widget.
#' @param url A WMTS tile URL template in WMTS REST `{z}/{y}/{x}` order, with the
#'   row before the column. This differs from the `{z}/{x}/{y}` templates
#'   [add_tile_layer()] expects.
#' @param name Layer name.
#' @param tile_size Tile size in pixels.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_wmts("https://example.com/wmts/layer/{z}/{y}/{x}.png", name = "Imagery")
#' stopifnot(map$x$project$layers[[1]]$type == "wmts")
#' @export
add_wmts <- function(map, url, name = "WMTS Layer", tile_size = 256, style = list(),
                     visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  append_layer(
    map,
    finish_layer(
      wmts_layer(name, url, tile_size = check_integer(tile_size, "tile_size"), style = style),
      visible, opacity
    )
  )
}

#' Add a WFS layer
#'
#' The `GetFeature` response is fetched and inlined into the project, so the
#' endpoint must be able to return GeoJSON. This function contacts the service
#' when called.
#'
#' @param map A GeoLibre widget.
#' @param endpoint WFS service endpoint.
#' @param type_name WFS feature type name, for example `"topp:states"`.
#' @param name Layer name.
#' @param version WFS protocol version, for example `"2.0.0"` or `"1.1.0"`.
#' @param output_format Requested output format; must yield GeoJSON.
#' @param srs_name Spatial reference of the response.
#' @param max_features Cap on the number of returned features, since the response
#'   is inlined. Pass `NULL` to request every feature.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' \dontrun{
#' geolibre() |>
#'   add_wfs("https://ahocevar.com/geoserver/wfs", type_name = "topp:states")
#' }
#' @export
add_wfs <- function(map, endpoint, type_name, name = "WFS Layer", version = "2.0.0",
                    output_format = "application/json", srs_name = "EPSG:4326",
                    max_features = 1000, style = list(), visible = TRUE,
                    opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(endpoint, "endpoint")
  check_string(type_name, "type_name")
  check_string(version, "version")
  if (!is.null(max_features)) max_features <- check_integer(max_features, "max_features")
  url <- wfs_getfeature_url(
    endpoint, type_name,
    version = version, output_format = output_format,
    srs_name = srs_name, max_features = max_features
  )
  collection <- as_featurecollection(url)
  layer <- geojson_layer(name, collection, source_url = url, style = style)
  # Mirror the protocol fields the interface persists on the source, so the Edit
  # Layer panel can pre-populate the WFS form when this project is reopened.
  layer$source <- c(
    layer$source,
    list(
      service = "wfs",
      typeName = type_name,
      version = version,
      outputFormat = output_format
    ),
    if (is_scalar_string(srs_name) && nzchar(srs_name)) list(srsName = srs_name) else list()
  )
  layer$metadata <- list(
    service = "wfs",
    sourceKind = "wfs-getfeature",
    typeName = type_name,
    featureCount = length(collection$features)
  )
  append_layer(map, finish_layer(layer, visible, opacity))
}

#' Add a vector tile layer from a TileJSON endpoint
#'
#' @param map A GeoLibre widget.
#' @param url TileJSON endpoint for the vector tileset.
#' @param name Layer name.
#' @param source_layers Source layer names to render, for multi-layer tilesets.
#' @param source_layer A single source layer name, for the common single-layer
#'   case. Ignored when `source_layers` is supplied.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_vector_tiles("https://example.com/tiles.json", source_layer = "roads")
#' stopifnot(map$x$project$layers[[1]]$type == "vector-tiles")
#' @export
add_vector_tiles <- function(map, url, name = "Vector Tiles", source_layers = NULL,
                             source_layer = NULL, style = list(), visible = TRUE,
                             opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  append_layer(
    map,
    finish_layer(
      vector_tiles_layer(
        name, url,
        source_layers = source_layers, source_layer = source_layer, style = style
      ),
      visible, opacity
    )
  )
}

#' Add a PMTiles layer
#'
#' The application registers the `pmtiles://` protocol itself, so a plain
#' `https://` URL to the archive is what this expects.
#'
#' @param map A GeoLibre widget.
#' @param url URL of the `.pmtiles` archive.
#' @param name Layer name.
#' @param tile_type `"vector"` or `"raster"`.
#' @param source_layers Vector source layer names to render. Vector tiles only.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_pmtiles("https://example.com/data.pmtiles", source_layers = "buildings")
#' stopifnot(map$x$project$layers[[1]]$type == "pmtiles")
#' @export
add_pmtiles <- function(map, url, name = "PMTiles", tile_type = c("vector", "raster"),
                        source_layers = NULL, style = list(), visible = TRUE,
                        opacity = 1, ...) {
  tile_type <- match.arg(tile_type)
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  append_layer(
    map,
    finish_layer(
      pmtiles_layer(
        name, url,
        tile_type = tile_type, source_layers = source_layers, style = style
      ),
      visible, opacity
    )
  )
}

#' Add a 3D Tiles layer
#'
#' @param map A GeoLibre widget.
#' @param url URL of the 3D Tiles `tileset.json`.
#' @param name Layer name.
#' @param altitude_offset Vertical offset applied to the tileset, in meters.
#' @param request_headers Optional named list of request headers. These are
#'   stored in the project, so avoid persisting secrets; [save_project()] strips
#'   them unless `keep_credentials = TRUE`.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_3d_tiles("https://example.com/tileset.json", altitude_offset = 20)
#' stopifnot(map$x$project$layers[[1]]$type == "3d-tiles")
#' @export
add_3d_tiles <- function(map, url, name = "3D Tiles", altitude_offset = 0,
                         request_headers = NULL, style = list(), visible = TRUE,
                         opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  check_http_url(url, "url")
  altitude_offset <- check_number(altitude_offset, "altitude_offset")
  if (!is.null(request_headers) &&
      (!is.list(request_headers) || is.null(names(request_headers)))) {
    stop_geolibre("`request_headers` must be NULL or a named list.")
  }
  append_layer(
    map,
    finish_layer(
      three_d_tiles_layer(
        name, url,
        altitude_offset = altitude_offset, request_headers = request_headers,
        style = style
      ),
      visible, opacity
    )
  )
}

#' Add a georeferenced video layer
#'
#' @param map A GeoLibre widget.
#' @param urls One video URL, or several as format fallbacks such as MP4 then
#'   WebM. URLs must be `https://`, since the browser's media policy blocks
#'   plain HTTP.
#' @param coordinates Four `c(longitude, latitude)` corners in top-left,
#'   top-right, bottom-right, bottom-left order, given as a list of pairs or a
#'   four-row matrix.
#' @param name Layer name.
#' @inheritParams add_geojson
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_video(
#'     "https://example.com/clip.mp4",
#'     coordinates = list(
#'       c(-77.1, 39.0), c(-77.0, 39.0), c(-77.0, 38.9), c(-77.1, 38.9)
#'     )
#'   )
#' stopifnot(map$x$project$layers[[1]]$type == "video")
#' @export
add_video <- function(map, urls, coordinates, name = "Video", style = list(),
                      visible = TRUE, opacity = 1, ...) {
  style <- merge_style(style, list(...))
  validate_layer_options(name, style, visible)
  append_layer(
    map,
    finish_layer(
      video_layer(name, as.character(unlist(urls, use.names = FALSE)), coordinates, style = style),
      visible, opacity
    )
  )
}
