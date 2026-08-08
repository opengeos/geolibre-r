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
#> 1 ffb37e1a-f2a1-4768-af39-b3bae7f8610b   Pin geojson    TRUE       1
#> 2 9dab3917-4a60-4de7-bf89-a931e27ee6cd Image     cog    TRUE       1
#>                          source features
#> 1                          <NA>        1
#> 2 https://example.com/image.tif       NA
```
