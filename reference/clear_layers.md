# Remove every layer

Remove every layer

## Usage

``` r
clear_layers(map)
```

## Arguments

- map:

  A GeoLibre widget.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39) |> clear_layers()
stopifnot(length(map$x$project$layers) == 0L)
```
