# Add a split-map comparison slider

Enables the Layer Swipe control, which clips one set of layers to one
side of a draggable slider and another set to the other, for
before-and-after comparisons.

## Usage

``` r
split_map(
  map,
  left_layers = NULL,
  right_layers = NULL,
  orientation = c("vertical", "horizontal"),
  position = 50,
  control_position = c("top-left", "top-right", "bottom-left", "bottom-right")
)
```

## Arguments

- map:

  A GeoLibre widget.

- left_layers:

  Layer ids or names shown on the left or top of the slider. The string
  `"__basemap__"` selects the basemap.

- right_layers:

  Layer ids or names shown on the right or bottom.

- orientation:

  `"vertical"` to move the slider left and right, or `"horizontal"` to
  move it up and down.

- position:

  Initial slider position as a percentage from 0 to 100.

- control_position:

  Corner for the swipe panel: `"top-left"`, `"top-right"`,
  `"bottom-left"`, or `"bottom-right"`.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_raster("https://example.com/before.tif", name = "Before") |>
  add_raster("https://example.com/after.tif", name = "After") |>
  split_map("Before", "After")
stopifnot(length(map$x$project$plugins$settings) == 1L)
```
