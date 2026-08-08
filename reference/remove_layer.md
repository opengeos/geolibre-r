# Remove a layer

Remove a layer

## Usage

``` r
remove_layer(map, layer)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  remove_layer("Pin")
stopifnot(length(map$x$project$layers) == 0L)
```
