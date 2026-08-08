# Center the map

Center the map

## Usage

``` r
set_center(map, lng, lat, zoom = NULL)
```

## Arguments

- map:

  A GeoLibre widget.

- lng:

  Longitude of the new center.

- lat:

  Latitude of the new center.

- zoom:

  Optional zoom level.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> set_center(-77.0369, 38.9072, zoom = 11)
stopifnot(map$x$project$mapView$zoom == 11)
```
