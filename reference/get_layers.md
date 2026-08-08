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
#> 1 03c71259-6de3-4975-bfb6-d4748c7771c8   Pin geojson    TRUE       1
#> 2 94589ad2-dcac-4ed7-a151-10be0557b849 Image     cog    TRUE       1
#>                          source features
#> 1                          <NA>        1
#> 2 https://example.com/image.tif       NA
```
