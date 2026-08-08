# Show or hide a layer

Show or hide a layer

## Usage

``` r
set_layer_visibility(map, layer, visible = TRUE)

show_layer(map, layer)

hide_layer(map, layer)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- visible:

  `TRUE` to show the layer, `FALSE` to hide it.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  set_layer_visibility("Pin", FALSE)
stopifnot(isFALSE(map$x$project$layers[[1]]$visible))
```
