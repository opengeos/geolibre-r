# Set the GeoLibre camera

Set the GeoLibre camera

## Usage

``` r
set_view(
  map,
  center = NULL,
  zoom = NULL,
  bearing = NULL,
  pitch = NULL,
  bbox = NULL
)
```

## Arguments

- map:

  A GeoLibre widget.

- center:

  Optional `c(longitude, latitude)` pair.

- zoom:

  Optional zoom level, clamped to between 0 and 24.

- bearing:

  Optional clockwise rotation in degrees.

- pitch:

  Optional tilt in degrees, clamped to between 0 and 85.

- bbox:

  Optional `c(west, south, east, north)` bounds. When supplied it takes
  precedence over `center` and `zoom`, and is resolved to a center and
  zoom by
  [`fit_bounds()`](https://r.geolibre.app/reference/fit_bounds.md).

## Value

The modified widget.

## See also

[`fit_bounds()`](https://r.geolibre.app/reference/fit_bounds.md),
[`set_center()`](https://r.geolibre.app/reference/set_center.md),
[`set_zoom()`](https://r.geolibre.app/reference/set_zoom.md)

## Examples

``` r
map <- geolibre() |>
  set_view(center = c(-77.0369, 38.9072), zoom = 10, pitch = 30)
stopifnot(map$x$project$mapView$zoom == 10)
```
