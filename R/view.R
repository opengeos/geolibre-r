# The saved camera, the basemap, and the project name.

# Web Mercator latitude limit. Outside it the projection is undefined.
MERCATOR_LATITUDE_LIMIT <- 85.051129

#' Set the GeoLibre camera
#'
#' @param map A GeoLibre widget.
#' @param center Optional `c(longitude, latitude)` pair.
#' @param zoom Optional zoom level, clamped to between 0 and 24.
#' @param bearing Optional clockwise rotation in degrees.
#' @param pitch Optional tilt in degrees, clamped to between 0 and 85.
#' @param bbox Optional `c(west, south, east, north)` bounds. When supplied it
#'   takes precedence over `center` and `zoom`, and is resolved to a center and
#'   zoom by [fit_bounds()].
#' @return The modified widget.
#' @seealso [fit_bounds()], [set_center()], [set_zoom()]
#' @examples
#' map <- geolibre() |>
#'   set_view(center = c(-77.0369, 38.9072), zoom = 10, pitch = 30)
#' stopifnot(map$x$project$mapView$zoom == 10)
#' @export
set_view <- function(map, center = NULL, zoom = NULL, bearing = NULL,
                     pitch = NULL, bbox = NULL) {
  if (!is.null(bbox)) {
    map <- fit_bounds(map, bbox)
    if (!is.null(bearing) || !is.null(pitch)) {
      map <- apply_view(map, bearing = bearing, pitch = pitch)
    }
    return(map)
  }
  apply_view(map, center = center, zoom = zoom, bearing = bearing, pitch = pitch)
}

# Write the supplied camera fields into the project's `mapView`.
apply_view <- function(map, center = NULL, zoom = NULL, bearing = NULL, pitch = NULL) {
  update_project(map, function(project) {
    view <- if (is.list(project$mapView)) project$mapView else default_map_view()
    if (!is.null(center)) view$center <- check_lnglat(center)
    if (!is.null(zoom)) view$zoom <- clamp(check_number(zoom, "zoom"), 0, 24)
    if (!is.null(center) || !is.null(zoom)) {
      # `bbox` describes the extent a previous fit computed. Moving the camera by
      # hand leaves it describing something else, and the application reads it
      # (the status bar's bounding-box readout), so drop it rather than persist a
      # stale one. Bearing and pitch do not change the extent.
      view$bbox <- NULL
    }
    if (!is.null(bearing)) view$bearing <- check_number(bearing, "bearing")
    if (!is.null(pitch)) view$pitch <- clamp(check_number(pitch, "pitch"), 0, 85)
    project$mapView <- view
    project
  })
}

#' Center the map
#'
#' @param map A GeoLibre widget.
#' @param lng Longitude of the new center.
#' @param lat Latitude of the new center.
#' @param zoom Optional zoom level.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> set_center(-77.0369, 38.9072, zoom = 11)
#' stopifnot(map$x$project$mapView$zoom == 11)
#' @export
set_center <- function(map, lng, lat, zoom = NULL) {
  apply_view(map, center = c(check_number(lng, "lng"), check_number(lat, "lat")), zoom = zoom)
}

#' Set the map zoom
#'
#' @param map A GeoLibre widget.
#' @param zoom Zoom level, clamped to between 0 and 24.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> set_zoom(6)
#' stopifnot(map$x$project$mapView$zoom == 6)
#' @export
set_zoom <- function(map, zoom) {
  apply_view(map, zoom = zoom)
}

#' Set the camera bearing
#'
#' @param map A GeoLibre widget.
#' @param bearing Clockwise rotation in degrees.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> set_bearing(45)
#' stopifnot(map$x$project$mapView$bearing == 45)
#' @export
set_bearing <- function(map, bearing) {
  apply_view(map, bearing = bearing)
}

#' Set the camera pitch
#'
#' @param map A GeoLibre widget.
#' @param pitch Tilt in degrees, clamped to between 0 and 85.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> set_pitch(60)
#' stopifnot(map$x$project$mapView$pitch == 60)
#' @export
set_pitch <- function(map, pitch) {
  apply_view(map, pitch = pitch)
}

#' Frame a bounding box
#'
#' A saved project records a center and zoom rather than a box to fit: the
#' application applies `mapView$center` and `mapView$zoom` verbatim when it opens
#' a project. So the box is resolved to a camera here, using an assumed viewport,
#' and recorded alongside it for reference. The result is approximate by
#' construction; expect the application's own "zoom to layer" to land within
#' roughly half a zoom level.
#'
#' @param map A GeoLibre widget.
#' @param bbox `c(west, south, east, north)` bounds. Per RFC 7946, a west
#'   greater than the east means the box crosses the antimeridian, and is framed
#'   as such.
#' @param padding Pixels of margin to leave around the box.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> fit_bounds(c(-125, 24, -66, 50))
#' round(map$x$project$mapView$zoom, 1)
#' @export
fit_bounds <- function(map, bbox, padding = 40) {
  box <- check_bbox(bbox)
  padding <- check_number(padding, "padding")
  if (padding < 0) stop_geolibre("`padding` must not be negative.")
  west <- box[[1]]
  south <- box[[2]]
  east <- box[[3]]
  north <- box[[4]]
  if (south > north) {
    stop_geolibre("`bbox` is inverted: south must not exceed north.")
  }
  if (south < -MERCATOR_LATITUDE_LIMIT || north > MERCATOR_LATITUDE_LIMIT) {
    stop_geolibre(
      "`bbox` latitudes must lie within +/-", MERCATOR_LATITUDE_LIMIT, " (Web Mercator)."
    )
  }
  # A box crossing the antimeridian is written with west > east, so Fiji is
  # c(170, -20, -170, -10). Its longitude span wraps through 180, and the center
  # follows it out past the meridian and back into [-180, 180].
  lng_span <- if (west > east) (east - west) %% 360 else east - west
  center_lng <- west + lng_span / 2
  if (center_lng > 180) center_lng <- center_lng - 360

  # The viewport the fit assumes. The application sizes the map to its container,
  # so the true value is only known at display time; this is a typical desktop
  # map pane.
  viewport <- c(1024, 768)
  tile_size <- 512
  usable <- c(
    max(1, viewport[[1]] - 2 * padding),
    max(1, viewport[[2]] - 2 * padding)
  )
  fractions <- c(
    lng_span / 360,
    abs(mercator_y(north) - mercator_y(south))
  )
  candidates <- vapply(
    seq_along(fractions),
    function(i) {
      if (fractions[[i]] <= 0) return(NA_real_)
      log2(usable[[i]] / (tile_size * fractions[[i]]))
    },
    numeric(1)
  )
  candidates <- candidates[!is.na(candidates)]
  # A degenerate (point) box has no extent to fit; fall back to a close-in zoom.
  zoom <- if (length(candidates)) min(candidates) else 14
  center_lat <- inverse_mercator_y((mercator_y(south) + mercator_y(north)) / 2)
  map <- apply_view(map, center = c(center_lng, center_lat), zoom = zoom)
  update_project(map, function(project) {
    project$mapView$bbox <- box
    project
  })
}

mercator_y <- function(lat) {
  sin_lat <- sin(lat * pi / 180)
  0.5 - log((1 + sin_lat) / (1 - sin_lat)) / (4 * pi)
}

inverse_mercator_y <- function(y) {
  (2 * atan(exp((0.5 - y) * 2 * pi)) - pi / 2) * 180 / pi
}

#' Set the background basemap
#'
#' @param map A GeoLibre widget.
#' @param basemap A basemap name from [basemaps()] or a MapLibre style JSON URL.
#' @return The modified widget.
#' @seealso [basemaps()], [add_tile_layer()] for raster basemaps such as
#'   OpenStreetMap.
#' @examples
#' map <- geolibre() |> set_basemap("dark")
#' map$x$project$basemapStyleUrl
#' @export
set_basemap <- function(map, basemap) {
  url <- resolve_basemap(basemap)
  update_project(map, function(project) {
    project$basemapStyleUrl <- url
    project
  })
}

#' @rdname set_basemap
#' @export
add_basemap <- function(map, basemap) {
  set_basemap(map, basemap)
}

#' Set the project name
#'
#' @param map A GeoLibre widget.
#' @param name The project's display name, as shown in the application and
#'   stored in the project file.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> set_project_name("Chesapeake Bay")
#' map$x$project$name
#' @export
set_project_name <- function(map, name) {
  name <- trimws(check_string(name, "name"))
  if (!nzchar(name)) stop_geolibre("`name` must be a single non-empty string.")
  update_project(map, function(project) {
    project$name <- name
    project
  })
}
