# Set the camera bearing

Set the camera bearing

## Usage

``` r
set_bearing(map, bearing)
```

## Arguments

- map:

  A GeoLibre widget.

- bearing:

  Clockwise rotation in degrees.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> set_bearing(45)
stopifnot(map$x$project$mapView$bearing == 45)
```
