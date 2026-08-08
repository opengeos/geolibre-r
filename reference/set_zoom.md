# Set the map zoom

Set the map zoom

## Usage

``` r
set_zoom(map, zoom)
```

## Arguments

- map:

  A GeoLibre widget.

- zoom:

  Zoom level, clamped to between 0 and 24.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> set_zoom(6)
stopifnot(map$x$project$mapView$zoom == 6)
```
