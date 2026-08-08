# Add a colorbar to the map

Renders a gradient with minimum and maximum ticks, from either a named
color ramp or an explicit list of CSS colors. Each call adds another
colorbar.

## Usage

``` r
add_colorbar(
  map,
  colormap = "viridis",
  vmin = 0,
  vmax = 1,
  label = "",
  units = "",
  colors = NULL,
  orientation = c("vertical", "horizontal"),
  position = c("bottom-right", "bottom-left", "top-left", "top-right")
)
```

## Arguments

- map:

  A GeoLibre widget.

- colormap:

  A color ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).
  Ignored when `colors` is supplied.

- vmin:

  Value at the low end of the colorbar.

- vmax:

  Value at the high end of the colorbar.

- label:

  Title shown alongside the colorbar.

- units:

  Units suffix shown with the values.

- colors:

  Optional character vector of CSS colors defining a custom gradient,
  used instead of `colormap`.

- orientation:

  `"vertical"` or `"horizontal"`.

- position:

  Corner for the colorbar: `"top-left"`, `"top-right"`, `"bottom-left"`,
  or `"bottom-right"`.

## Value

The modified widget.

## See also

[`add_legend()`](https://r.geolibre.app/reference/add_legend.md) for
categorical classes

## Examples

``` r
map <- geolibre() |>
  add_raster("https://example.com/dem.tif", bands = 1, colormap = "terrain") |>
  add_colorbar(
    colormap = "terrain", vmin = 0, vmax = 3000,
    label = "Elevation", units = "m"
  )
```
