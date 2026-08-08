# Add a legend to the map

Supply the legend entries exactly one of three ways: a built-in preset
(`builtin`), a named vector or list of label-to-color pairs (`legend`),
or parallel `labels` and `colors` vectors. Each call adds another
legend, so a map can carry several at once.

## Usage

``` r
add_legend(
  map,
  title = NULL,
  legend = NULL,
  labels = NULL,
  colors = NULL,
  builtin = NULL,
  position = c("bottom-left", "bottom-right", "top-left", "top-right"),
  shape = c("square", "circle", "line")
)
```

## Arguments

- map:

  A GeoLibre widget.

- title:

  Legend title. Defaults to `"Legend"`, or the preset's own title when
  `builtin` is supplied without one.

- legend:

  A named vector or list mapping label to CSS color. Order is preserved.

- labels:

  Item labels, paired position-wise with `colors`.

- colors:

  Item CSS colors, paired position-wise with `labels`.

- builtin:

  A built-in preset name from
  [`builtin_legend_names()`](https://r.geolibre.app/reference/builtin_legend_names.md).

- position:

  Corner for the legend: `"top-left"`, `"top-right"`, `"bottom-left"`,
  or `"bottom-right"`.

- shape:

  Swatch shape for every item: `"square"`, `"circle"`, or `"line"`.

## Value

The modified widget.

## See also

[`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md) for
continuous rasters,
[`builtin_legend_names()`](https://r.geolibre.app/reference/builtin_legend_names.md)

## Examples

``` r
map <- geolibre() |>
  add_legend(
    "Land cover",
    legend = c(Water = "#466b9f", Forest = "#1c5f2c"),
    position = "bottom-left"
  )

# A built-in preset carries its own title and colors.
geolibre() |> add_legend(builtin = "nlcd")

{"x":{"project":{"version":"0.2.0","name":"Untitled Project","mapView":{"center":[-100,40],"zoom":2,"bearing":0,"pitch":0},"basemapStyleUrl":"https://tiles.openfreemap.org/styles/liberty","basemapVisible":true,"basemapOpacity":1,"layers":[],"styles":{},"preferences":{"map":{"restrictBounds":false,"bounds":[-180,-85,180,85],"minZoom":0,"maxZoom":24,"maxPitch":85,"renderWorldCopies":true},"environmentVariables":[]},"metadata":{},"plugins":{"manifestUrls":[],"activePluginIds":["maplibre-layer-control","maplibre-deckgl-viz","maplibre-atmosphere-effects"],"mapControlPositions":{},"settings":{"maplibre-gl-components":{"legend":{"title":"NLCD Land Cover","items":[{"label":"Open Water","color":"#466b9f","shape":"square"},{"label":"Perennial Ice/Snow","color":"#d1def8","shape":"square"},{"label":"Developed, Open Space","color":"#dec5c5","shape":"square"},{"label":"Developed, Low Intensity","color":"#d99282","shape":"square"},{"label":"Developed, Medium Intensity","color":"#eb0000","shape":"square"},{"label":"Developed, High Intensity","color":"#ab0000","shape":"square"},{"label":"Barren Land","color":"#b3ac9f","shape":"square"},{"label":"Deciduous Forest","color":"#68ab5f","shape":"square"},{"label":"Evergreen Forest","color":"#1c5f2c","shape":"square"},{"label":"Mixed Forest","color":"#b5c58f","shape":"square"},{"label":"Dwarf Scrub","color":"#af963c","shape":"square"},{"label":"Shrub/Scrub","color":"#ccb879","shape":"square"},{"label":"Grassland/Herbaceous","color":"#dfdfc2","shape":"square"},{"label":"Sedge/Herbaceous","color":"#d1d182","shape":"square"},{"label":"Lichens","color":"#a3cc51","shape":"square"},{"label":"Moss","color":"#82ba9e","shape":"square"},{"label":"Pasture/Hay","color":"#dcd939","shape":"square"},{"label":"Cultivated Crops","color":"#ab6c28","shape":"square"},{"label":"Woody Wetlands","color":"#b8d9eb","shape":"square"},{"label":"Emergent Herbaceous Wetlands","color":"#6c9fb8","shape":"square"}],"legendPosition":"bottom-left","visible":true,"collapsed":false,"hasLegend":true,"selectedLegendIndex":0,"legends":[{"title":"NLCD Land Cover","items":[{"label":"Open Water","color":"#466b9f","shape":"square"},{"label":"Perennial Ice/Snow","color":"#d1def8","shape":"square"},{"label":"Developed, Open Space","color":"#dec5c5","shape":"square"},{"label":"Developed, Low Intensity","color":"#d99282","shape":"square"},{"label":"Developed, Medium Intensity","color":"#eb0000","shape":"square"},{"label":"Developed, High Intensity","color":"#ab0000","shape":"square"},{"label":"Barren Land","color":"#b3ac9f","shape":"square"},{"label":"Deciduous Forest","color":"#68ab5f","shape":"square"},{"label":"Evergreen Forest","color":"#1c5f2c","shape":"square"},{"label":"Mixed Forest","color":"#b5c58f","shape":"square"},{"label":"Dwarf Scrub","color":"#af963c","shape":"square"},{"label":"Shrub/Scrub","color":"#ccb879","shape":"square"},{"label":"Grassland/Herbaceous","color":"#dfdfc2","shape":"square"},{"label":"Sedge/Herbaceous","color":"#d1d182","shape":"square"},{"label":"Lichens","color":"#a3cc51","shape":"square"},{"label":"Moss","color":"#82ba9e","shape":"square"},{"label":"Pasture/Hay","color":"#dcd939","shape":"square"},{"label":"Cultivated Crops","color":"#ab6c28","shape":"square"},{"label":"Woody Wetlands","color":"#b8d9eb","shape":"square"},{"label":"Emergent Herbaceous Wetlands","color":"#6c9fb8","shape":"square"}],"legendPosition":"bottom-left"}]}}}}},"appUrl":"https://web.geolibre.app/","layout":"embed","theme":"light","panels":"expanded"},"evals":[],"jsHooks":[]}
```
