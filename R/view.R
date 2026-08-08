#' Set the GeoLibre camera
#'
#' @param map A GeoLibre widget.
#' @param center Optional longitude/latitude pair.
#' @param zoom,bearing,pitch Optional camera values.
#' @param bbox Optional west/south/east/north bounds. When supplied it takes
#'   precedence over `center` and `zoom`.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   set_view(center = c(-77.0369, 38.9072), zoom = 10, pitch = 30)
#' stopifnot(map$x$project$mapView$zoom == 10)
#' @export
set_view <- function(map, center = NULL, zoom = NULL, bearing = NULL,
                     pitch = NULL, bbox = NULL) {
  project <- widget_project(map)
  view <- project$mapView
  is_scalar_number <- function(value) {
    is.numeric(value) && length(value) == 1L && is.finite(value)
  }
  if (!is.null(bbox)) {
    if (!is.numeric(bbox) || length(bbox) != 4L || any(!is.finite(bbox))) {
      stop("`bbox` must have four finite numeric values.", call. = FALSE)
    }
    view$bounds <- unname(bbox)
  } else {
    view$bounds <- NULL
    if (!is.null(center)) {
      if (!is.numeric(center) || length(center) != 2L || any(!is.finite(center))) {
        stop("`center` must be c(longitude, latitude) with two finite numeric values.", call. = FALSE)
      }
      view$center <- unname(center)
    }
    if (!is.null(zoom)) {
      if (!is_scalar_number(zoom)) stop("`zoom` must be one finite numeric value.", call. = FALSE)
      view$zoom <- unname(zoom)
    }
  }
  if (!is.null(bearing)) {
    if (!is_scalar_number(bearing)) stop("`bearing` must be one finite numeric value.", call. = FALSE)
    view$bearing <- unname(bearing)
  }
  if (!is.null(pitch)) {
    if (!is_scalar_number(pitch)) stop("`pitch` must be one finite numeric value.", call. = FALSE)
    view$pitch <- unname(pitch)
  }
  project$mapView <- view
  set_widget_project(map, project)
}
