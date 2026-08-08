# Summarize a project's layers

Summarize a project's layers

## Usage

``` r
get_layers(x)
```

## Arguments

- x:

  A GeoLibre widget or a project list.

## Value

A data frame with one row per layer, in draw order, holding its `id`,
`name`, `type`, `visible`, `opacity`, `source` URL (credentials
stripped), and inlined `features` count.

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  add_raster("https://example.com/image.tif", name = "Image")
get_layers(map)
#>                                     id  name    type visible opacity
#> 1 f1afd7bf-5818-4248-8d3a-475943e0571f   Pin geojson    TRUE       1
#> 2 66a38505-63f9-4042-9002-27279457f411 Image     cog    TRUE       1
#>                          source features
#> 1                          <NA>        1
#> 2 https://example.com/image.tif       NA
```
