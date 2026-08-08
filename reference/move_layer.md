# Move a layer in the draw order

Move a layer in the draw order

## Usage

``` r
move_layer(map, layer, index)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- index:

  One-based destination position, counted from the bottom of the draw
  order. Negative values count from the top, so `-1` moves the layer to
  the very top. Out-of-range values are clamped.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Bottom") |>
  add_marker(-76, 40, name = "Top") |>
  move_layer("Top", 1)
stopifnot(layer_names(map)[[1]] == "Top")
```
