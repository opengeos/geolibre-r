# Restyle a layer

Merges style overrides into a layer's existing style. Keys not mentioned
keep their current values.

## Usage

``` r
set_layer_style(map, layer, style = list(), ...)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- style:

  Named list of style keys to set.

- ...:

  Additional style overrides given as named arguments.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  set_layer_style("Pin", fillColor = "#f59e0b", circleRadius = 9)
stopifnot(map$x$project$layers[[1]]$style$fillColor == "#f59e0b")
```
