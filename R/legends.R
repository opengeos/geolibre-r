# Built-in legend presets for `add_legend()`, mirroring the land-cover legends
# shipped by the GeoLibre Python API (and leafmap/geemap before it) so a
# recognizable legend can be drawn from a single name.

BUILTIN_LEGENDS <- list(
  nlcd = list(
    title = "NLCD Land Cover",
    labels = c(
      "Open Water", "Perennial Ice/Snow", "Developed, Open Space",
      "Developed, Low Intensity", "Developed, Medium Intensity",
      "Developed, High Intensity", "Barren Land", "Deciduous Forest",
      "Evergreen Forest", "Mixed Forest", "Dwarf Scrub", "Shrub/Scrub",
      "Grassland/Herbaceous", "Sedge/Herbaceous", "Lichens", "Moss",
      "Pasture/Hay", "Cultivated Crops", "Woody Wetlands",
      "Emergent Herbaceous Wetlands"
    ),
    colors = c(
      "#466b9f", "#d1def8", "#dec5c5", "#d99282", "#eb0000", "#ab0000",
      "#b3ac9f", "#68ab5f", "#1c5f2c", "#b5c58f", "#af963c", "#ccb879",
      "#dfdfc2", "#d1d182", "#a3cc51", "#82ba9e", "#dcd939", "#ab6c28",
      "#b8d9eb", "#6c9fb8"
    )
  ),
  esa_worldcover = list(
    title = "ESA WorldCover",
    labels = c(
      "Tree cover", "Shrubland", "Grassland", "Cropland", "Built-up",
      "Bare / sparse vegetation", "Snow and ice", "Permanent water bodies",
      "Herbaceous wetland", "Mangroves", "Moss and lichen"
    ),
    colors = c(
      "#006400", "#ffbb22", "#ffff4c", "#f096ff", "#fa0000", "#b4b4b4",
      "#f0f0f0", "#0064c8", "#0096a0", "#00cf75", "#fae6a0"
    )
  )
)

LEGEND_ALIASES <- c(
  esa = "esa_worldcover",
  worldcover = "esa_worldcover",
  esa_world_cover = "esa_worldcover",
  nlcd_land_cover = "nlcd"
)

#' Built-in legend preset names
#'
#' The preset names accepted by the `builtin` argument of [add_legend()].
#'
#' @return A character vector of preset names.
#' @examples
#' builtin_legend_names()
#' @export
builtin_legend_names <- function() {
  sort(names(BUILTIN_LEGENDS))
}

get_builtin_legend <- function(name) {
  key <- tolower(trimws(as.character(name)[[1]]))
  if (key %in% names(LEGEND_ALIASES)) key <- unname(LEGEND_ALIASES[[key]])
  if (!key %in% names(BUILTIN_LEGENDS)) {
    stop_geolibre(
      "Unknown built-in legend \"", name, "\". Available presets: ",
      paste(builtin_legend_names(), collapse = ", "), "."
    )
  }
  BUILTIN_LEGENDS[[key]]
}
