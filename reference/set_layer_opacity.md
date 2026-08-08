# Set a layer's opacity

Set a layer's opacity

## Usage

``` r
set_layer_opacity(map, layer, opacity)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- opacity:

  Opacity from zero to one.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  set_layer_opacity("Pin", 0.4)
stopifnot(map$x$project$layers[[1]]$opacity == 0.4)
```
