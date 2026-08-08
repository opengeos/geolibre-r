#' Set the GeoLibre camera
#'
#' @param map A GeoLibre widget.
#' @param center Optional longitude/latitude pair.
#' @param zoom,bearing,pitch Optional camera values.
#' @param bbox Optional west/south/east/north bounds. When supplied it takes
#'   precedence over `center` and `zoom`.
#' @return The modified widget.
#' @export
set_view <- function(map, center = NULL, zoom = NULL, bearing = NULL,
                     pitch = NULL, bbox = NULL) {
  project <- widget_project(map)
  view <- project$mapView
  if (!is.null(bbox)) {
    if (!is.numeric(bbox) || length(bbox) != 4L) stop("`bbox` must have four numeric values.", call. = FALSE)
    view$bounds <- unname(bbox)
  } else {
    view$bounds <- NULL
    if (!is.null(center)) {
      if (!is.numeric(center) || length(center) != 2L) stop("`center` must be c(longitude, latitude).", call. = FALSE)
      view$center <- unname(center)
    }
    if (!is.null(zoom)) view$zoom <- unname(zoom)
  }
  if (!is.null(bearing)) view$bearing <- unname(bearing)
  if (!is.null(pitch)) view$pitch <- unname(pitch)
  project$mapView <- view
  set_widget_project(map, project)
}
