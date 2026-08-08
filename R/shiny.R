#' Shiny bindings for GeoLibre
#'
#' @param outputId Output variable to read from.
#' @param width,height Widget dimensions.
#' @return `geolibreOutput()` returns a Shiny output element;
#'   `renderGeolibre()` returns a render function for it.
#' @section Shiny inputs:
#' A rendered widget reports back through four inputs, where `id` is the
#' `outputId`:
#'
#' * `input$id_project` — the full project each time the user edits the map.
#' * `input$id_error` — the message from a project the application rejected.
#' * `input$id_result` — the reply to a proxy command; a list with `requestId`,
#'   `method`, `ok`, and then `value` or `error`.
#' * `input$id_event` — user interaction; a list with `event`, one of `"click"`,
#'   `"selection-change"`, or `"layer-change"`, and its `payload`.
#' @examples
#' if (requireNamespace("shiny", quietly = TRUE)) {
#'   output <- geolibreOutput("map", height = "500px")
#'   stopifnot(inherits(output, "shiny.tag.list"))
#' }
#' @export
geolibreOutput <- function(outputId, width = "100%", height = "700px") {
  require_suggested("shiny", "geolibreOutput()")
  htmlwidgets::shinyWidgetOutput(outputId, "geolibre", width, height, package = "geolibre")
}

#' @param expr An expression that generates a GeoLibre widget.
#' @param env Environment in which to evaluate `expr`.
#' @param quoted Whether `expr` is quoted.
#' @rdname geolibreOutput
#' @export
renderGeolibre <- function(expr, env = parent.frame(), quoted = FALSE) {
  require_suggested("shiny", "renderGeolibre()")
  if (!quoted) expr <- substitute(expr)
  htmlwidgets::shinyRenderWidget(expr, geolibreOutput, env, quoted = TRUE)
}

#' Create a GeoLibre Shiny proxy
#'
#' A proxy addresses a widget that is already on screen, so a Shiny app can
#' replace its project with [update_geolibre()] or drive the live map with the
#' `geolibre_*()` command functions, without re-rendering the widget.
#'
#' @param outputId ID of an existing GeoLibre widget.
#' @param session A Shiny session. Defaults to the current reactive domain.
#' @return A `geolibre_proxy` object.
#' @seealso [update_geolibre()], [geolibre_fly_to()], [geolibre_command()]
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   proxy <- geolibre_proxy("map")
#' }
#' @export
geolibre_proxy <- function(outputId, session = NULL) {
  require_suggested("shiny", "geolibre_proxy()")
  if (is.null(session)) session <- shiny::getDefaultReactiveDomain()
  if (is.null(session)) {
    stop_geolibre("`session` must be provided outside a reactive context.")
  }
  structure(list(id = session$ns(outputId), session = session), class = "geolibre_proxy")
}

#' Replace the project displayed by a GeoLibre Shiny widget
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param map A GeoLibre widget or project list.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   update_geolibre(geolibre_proxy("map"), geolibre())
#' }
#' @export
update_geolibre <- function(proxy, map) {
  check_proxy(proxy)
  project <- as_project_list(map)
  proxy$session$sendCustomMessage(
    "geolibre:update",
    list(id = proxy$id, project = project)
  )
  invisible(proxy)
}

check_proxy <- function(proxy) {
  if (!inherits(proxy, "geolibre_proxy")) {
    stop_geolibre("`proxy` must be a GeoLibre proxy created by geolibre_proxy().")
  }
  invisible(TRUE)
}

#' Send a command to a live GeoLibre map
#'
#' The escape hatch behind the `geolibre_*()` command functions: it forwards any
#' method the application's scripting bridge implements. The reply arrives
#' asynchronously on the `input$id_result` input described in [geolibreOutput()].
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param method The scripting method name, for example `"flyTo"` or `"toImage"`.
#' @param params Named list of parameters for the method.
#' @param request_id Optional id echoed back with the reply, so several in-flight
#'   commands can be told apart. Generated when omitted.
#' @return The proxy, invisibly.
#' @seealso [geolibre_fly_to()], [geolibre_get_view()], [geolibre_run_algorithm()]
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_command(geolibre_proxy("map"), "zoomToLayer", list(layerId = "abc"))
#' }
#' @export
geolibre_command <- function(proxy, method, params = list(), request_id = NULL) {
  check_proxy(proxy)
  check_string(method, "method")
  if (!is.list(params)) stop_geolibre("`params` must be a named list.")
  if (length(params) && (is.null(names(params)) || any(!nzchar(names(params))))) {
    stop_geolibre("`params` must be a named list.")
  }
  if (is.null(request_id)) request_id <- new_uuid()
  check_string(request_id, "request_id")
  proxy$session$sendCustomMessage(
    "geolibre:command",
    list(
      id = proxy$id,
      requestId = request_id,
      method = method,
      params = if (length(params)) params else empty_object()
    )
  )
  invisible(proxy)
}

#' Animate the camera of a live GeoLibre map
#'
#' Unlike [set_view()], which records the camera a project opens at, this
#' animates the map that is already on screen. Omitted fields keep their current
#' value.
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param center Optional `c(longitude, latitude)` target.
#' @param zoom Optional target zoom level.
#' @param bearing Optional target bearing in degrees.
#' @param pitch Optional target pitch in degrees.
#' @param duration Optional animation duration in milliseconds.
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_fly_to(geolibre_proxy("map"), center = c(-77.0369, 38.9072), zoom = 12)
#' }
#' @export
geolibre_fly_to <- function(proxy, center = NULL, zoom = NULL, bearing = NULL,
                            pitch = NULL, duration = NULL, request_id = NULL) {
  params <- list()
  if (!is.null(center)) params$center <- check_lnglat(center)
  if (!is.null(zoom)) params$zoom <- check_number(zoom, "zoom")
  if (!is.null(bearing)) params$bearing <- check_number(bearing, "bearing")
  if (!is.null(pitch)) params$pitch <- check_number(pitch, "pitch")
  if (!is.null(duration)) params$duration <- check_number(duration, "duration")
  if (!length(params)) {
    stop_geolibre("Supply at least one of `center`, `zoom`, `bearing`, `pitch`, or `duration`.")
  }
  geolibre_command(proxy, "flyTo", params, request_id)
}

#' Fit a live GeoLibre map to a bounding box
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param bbox `c(west, south, east, north)` bounds.
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_fit_bounds(geolibre_proxy("map"), c(-125, 24, -66, 50))
#' }
#' @export
geolibre_fit_bounds <- function(proxy, bbox, request_id = NULL) {
  geolibre_command(proxy, "fitBounds", list(bounds = check_bbox(bbox)), request_id)
}

#' Zoom a live GeoLibre map to a layer's extent
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param layer_id The layer's id, as reported by [get_layers()].
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_zoom_to_layer(geolibre_proxy("map"), "layer-id")
#' }
#' @export
geolibre_zoom_to_layer <- function(proxy, layer_id, request_id = NULL) {
  check_string(layer_id, "layer_id")
  geolibre_command(proxy, "zoomToLayer", list(layerId = layer_id), request_id)
}

#' Read the camera of a live GeoLibre map
#'
#' The reply arrives on `input$id_result` with a `value` holding `center`, `zoom`,
#' `bearing`, `pitch`, and the current `bbox`.
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_get_view(geolibre_proxy("map"))
#' }
#' @export
geolibre_get_view <- function(proxy, request_id = NULL) {
  geolibre_command(proxy, "getView", list(), request_id)
}

#' Identify features at a point on a live GeoLibre map
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param lnglat `c(longitude, latitude)` of the point to query.
#' @param layer_id Optional layer id to restrict the query to.
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_identify(geolibre_proxy("map"), c(-77.0369, 38.9072))
#' }
#' @export
geolibre_identify <- function(proxy, lnglat, layer_id = NULL, request_id = NULL) {
  params <- list(lngLat = check_lnglat(lnglat, "lnglat"))
  if (!is.null(layer_id)) params$layerId <- check_string(layer_id, "layer_id")
  geolibre_command(proxy, "identify", params, request_id)
}

#' Read features from a live GeoLibre map
#'
#' `geolibre_layer_features()` returns one layer's features,
#' `geolibre_selected_features()` the current selection, and
#' `geolibre_drawn_features()` whatever the user drew with the map's editing
#' tools. Each reply arrives on `input$id_result`.
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param layer_id The layer's id, as reported by [get_layers()].
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_drawn_features(geolibre_proxy("map"))
#' }
#' @export
geolibre_layer_features <- function(proxy, layer_id, request_id = NULL) {
  check_string(layer_id, "layer_id")
  geolibre_command(proxy, "getLayerFeatures", list(layerId = layer_id), request_id)
}

#' @rdname geolibre_layer_features
#' @export
geolibre_selected_features <- function(proxy, request_id = NULL) {
  geolibre_command(proxy, "getSelectedFeatures", list(), request_id)
}

#' @rdname geolibre_layer_features
#' @export
geolibre_drawn_features <- function(proxy, request_id = NULL) {
  geolibre_command(proxy, "getDrawnFeatures", list(), request_id)
}

#' Run a processing algorithm on a live GeoLibre map
#'
#' `geolibre_list_algorithms()` reports the available tools with their
#' parameters; `geolibre_run_algorithm()` runs one in the browser. Results arrive
#' on `input$id_result`, and any output layers are added to the map.
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param algorithm The algorithm id, as reported by
#'   `geolibre_list_algorithms()`.
#' @param params Named list of algorithm parameters.
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   proxy <- geolibre_proxy("map")
#'   geolibre_list_algorithms(proxy)
#'   geolibre_run_algorithm(proxy, "buffer", list(layerId = "abc", distance = 500))
#' }
#' @export
geolibre_run_algorithm <- function(proxy, algorithm, params = list(), request_id = NULL) {
  check_string(algorithm, "algorithm")
  if (!is.list(params)) stop_geolibre("`params` must be a named list.")
  geolibre_command(
    proxy,
    "runAlgorithm",
    list(id = algorithm, params = if (length(params)) params else empty_object()),
    request_id
  )
}

#' @rdname geolibre_run_algorithm
#' @export
geolibre_list_algorithms <- function(proxy, request_id = NULL) {
  geolibre_command(proxy, "listAlgorithms", list(), request_id)
}

#' Capture a live GeoLibre map as a PNG
#'
#' The reply arrives on `input$id_result` with a `value` holding a
#' `data:image/png;base64,...` URL. Strip the prefix up to the comma and pass the
#' rest to [jsonlite::base64_dec()] to recover the PNG bytes.
#'
#' @param proxy A GeoLibre proxy created by [geolibre_proxy()].
#' @param request_id Optional id echoed back with the reply.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   geolibre_to_image(geolibre_proxy("map"))
#' }
#' @export
geolibre_to_image <- function(proxy, request_id = NULL) {
  geolibre_command(proxy, "toImage", list(), request_id)
}
