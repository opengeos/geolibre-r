# Sample a layer's feature properties

Lets you discover what an inlined vector layer can be styled or filtered
by without reading every feature back.

## Usage

``` r
layer_properties(x, layer)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

- layer:

  A layer id or layer name.

## Value

A named list mapping each property name to up to 25 distinct sample
values, in first-seen order.

## Examples

``` r
point <- list(
  type = "Feature", properties = list(name = "DC", pop = 700000),
  geometry = list(type = "Point", coordinates = c(-77, 39))
)
map <- geolibre() |> add_geojson(point, name = "Places")
layer_properties(map, "Places")
#> $name
#> $name[[1]]
#> [1] "DC"
#> 
#> 
#> $pop
#> $pop[[1]]
#> [1] 7e+05
#> 
#> 
```
