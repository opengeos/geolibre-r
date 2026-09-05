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
#> 1 de03e3b3-9e3e-487c-b2a2-0f21f7efb9fa   Pin geojson    TRUE       1
#> 2 dc026c17-3304-4510-8e59-685767c9bd34 Image     cog    TRUE       1
#>                          source features
#> 1                          <NA>        1
#> 2 https://example.com/image.tif       NA
```
