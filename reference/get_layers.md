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
#> 1 4c23f219-34f5-4627-b1c0-6abfada63ba6   Pin geojson    TRUE       1
#> 2 df77b8fc-2b1e-4b90-90e0-2f4df90a3c00 Image     cog    TRUE       1
#>                          source features
#> 1                          <NA>        1
#> 2 https://example.com/image.tif       NA
```
