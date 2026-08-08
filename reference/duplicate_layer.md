# Duplicate a layer

The copy is appended to the top of the draw order, where a newly added
layer lands. Use
[`move_layer()`](https://r.geolibre.app/reference/move_layer.md) to put
it elsewhere.

## Usage

``` r
duplicate_layer(map, layer, name = NULL)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- name:

  Name for the copy. Defaults to the source name followed by `" copy"`.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  duplicate_layer("Pin")
stopifnot(layer_names(map)[[2]] == "Pin copy")
```
