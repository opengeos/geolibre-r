# Rename a layer

Rename a layer

## Usage

``` r
rename_layer(map, layer, name)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name.

- name:

  The new display name. Surrounding whitespace is stripped.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  rename_layer("Pin", "Capital")
stopifnot(layer_names(map) == "Capital")
```
