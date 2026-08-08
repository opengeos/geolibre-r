# Set the camera pitch

Set the camera pitch

## Usage

``` r
set_pitch(map, pitch)
```

## Arguments

- map:

  A GeoLibre widget.

- pitch:

  Tilt in degrees, clamped to between 0 and 85.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> set_pitch(60)
stopifnot(map$x$project$mapView$pitch == 60)
```
