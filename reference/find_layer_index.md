# Position of a layer in the draw order

Position of a layer in the draw order

## Usage

``` r
find_layer_index(x, name)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

- name:

  A layer id or layer name.

## Value

The one-based index of the first matching layer, or `-1` when none
matches. Unlike the functions that modify a layer, a name several layers
share resolves to the first of them rather than raising.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39, name = "Pin")
find_layer_index(map, "Pin")
#> [1] 1
find_layer_index(map, "Missing")
#> [1] -1
```
