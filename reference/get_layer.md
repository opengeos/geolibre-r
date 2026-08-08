# Read one layer's full definition

Read one layer's full definition

## Usage

``` r
get_layer(x, layer)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

- layer:

  A layer id or layer name.

## Value

The layer as a list, with credential-bearing fields stripped.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39, name = "Pin")
get_layer(map, "Pin")$type
#> [1] "geojson"
```
