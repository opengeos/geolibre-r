# Named MapLibre basemap styles, mirroring `BASEMAPS` in the GeoLibre Python API
# and `DEFAULT_BASEMAP` in the application's core package.

DEFAULT_BASEMAP <- "https://tiles.openfreemap.org/styles/liberty"

GEOLIBRE_BASEMAPS <- c(
  liberty = "https://tiles.openfreemap.org/styles/liberty",
  bright = "https://tiles.openfreemap.org/styles/bright",
  positron = "https://tiles.openfreemap.org/styles/positron",
  dark = "https://tiles.openfreemap.org/styles/dark",
  fiord = "https://tiles.openfreemap.org/styles/fiord"
)

#' Named GeoLibre basemaps
#'
#' Lists the vector basemap styles that [set_basemap()] and [geolibre()] accept
#' by name. Raster tile basemaps such as OpenStreetMap are added as layers with
#' [add_tile_layer()] instead.
#'
#' @return A named character vector mapping basemap name to MapLibre style URL.
#' @examples
#' basemaps()
#' names(basemaps())
#' @export
basemaps <- function() {
  GEOLIBRE_BASEMAPS
}

# Resolve a basemap name or style URL to a style URL.
resolve_basemap <- function(basemap) {
  if (!is_scalar_string(basemap) || !nzchar(trimws(basemap))) {
    stop_geolibre("`basemap` must be a single non-empty string.")
  }
  value <- trimws(basemap)
  if (grepl("^https?://", value)) return(value)
  key <- tolower(value)
  if (!key %in% names(GEOLIBRE_BASEMAPS)) {
    stop_geolibre(
      "Unknown basemap \"", basemap, "\". Expected a style URL or one of: ",
      paste(sort(names(GEOLIBRE_BASEMAPS)), collapse = ", "), "."
    )
  }
  unname(GEOLIBRE_BASEMAPS[[key]])
}
