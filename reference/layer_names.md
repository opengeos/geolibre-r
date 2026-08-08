# Layer names in draw order

Layer names in draw order

## Usage

``` r
layer_names(x)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

## Value

A character vector of layer names, bottom layer first.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39, name = "Pin")
layer_names(map)
#> [1] "Pin"
```
