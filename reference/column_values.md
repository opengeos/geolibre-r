# Read one feature property across a layer

Read one feature property across a layer

## Usage

``` r
column_values(x, layer, column)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

- layer:

  A layer id or layer name.

- column:

  The feature property name.

## Value

A list of the raw values, one per feature, with `NULL` where the
property is absent.

## Examples

``` r
point <- list(
  type = "Feature", properties = list(pop = 700000),
  geometry = list(type = "Point", coordinates = c(-77, 39))
)
map <- geolibre() |> add_geojson(point, name = "Places")
column_values(map, "Places", "pop")
#> [[1]]
#> [1] 7e+05
#> 
```
