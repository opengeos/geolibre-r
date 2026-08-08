#' Shiny bindings for GeoLibre
#'
#' @param outputId Output variable to read from.
#' @param width,height Widget dimensions.
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
#' @param outputId ID of an existing GeoLibre widget.
#' @param session A Shiny session.
#' @return A proxy object.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   proxy <- geolibre_proxy("map")
#' }
#' @export
geolibre_proxy <- function(outputId, session = NULL) {
  require_suggested("shiny", "geolibre_proxy()")
  if (is.null(session)) session <- shiny::getDefaultReactiveDomain()
  if (is.null(session)) stop("`session` must be provided outside a reactive context.", call. = FALSE)
  structure(list(id = session$ns(outputId), session = session), class = "geolibre_proxy")
}

require_suggested <- function(package, caller) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("Package `", package, "` is required by ", caller, ".", call. = FALSE)
  }
}

#' Replace the project displayed by a GeoLibre Shiny widget
#'
#' @param proxy A GeoLibre proxy created by `geolibre_proxy()`.
#' @param map A GeoLibre widget or project list.
#' @return The proxy, invisibly.
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   update_geolibre(geolibre_proxy("map"), geolibre())
#' }
#' @export
update_geolibre <- function(proxy, map) {
  if (!inherits(proxy, "geolibre_proxy")) stop("`proxy` must be a GeoLibre proxy.", call. = FALSE)
  project <- if (inherits(map, "geolibre")) widget_project(map) else normalize_project(map)
  proxy$session$sendCustomMessage("geolibre:update", list(id = proxy$id, project = project))
  invisible(proxy)
}
