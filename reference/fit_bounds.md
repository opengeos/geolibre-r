# Frame a bounding box

A saved project records a center and zoom rather than a box to fit: the
application applies `mapView$center` and `mapView$zoom` verbatim when it
opens a project. So the box is resolved to a camera here, using an
assumed viewport, and recorded alongside it for reference. The result is
approximate by construction; expect the application's own "zoom to
layer" to land within roughly half a zoom level.

## Usage

``` r
fit_bounds(map, bbox, padding = 40)
```

## Arguments

- map:

  A GeoLibre widget.

- bbox:

  `c(west, south, east, north)` bounds. Per RFC 7946, a west greater
  than the east means the box crosses the antimeridian, and is framed as
  such.

- padding:

  Pixels of margin to leave around the box.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> fit_bounds(c(-125, 24, -66, 50))
round(map$x$project$mapView$zoom, 1)
#> [1] 3.5
```
