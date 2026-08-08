# Animate the camera of a live GeoLibre map

Unlike [`set_view()`](https://r.geolibre.app/reference/set_view.md),
which records the camera a project opens at, this animates the map that
is already on screen. Omitted fields keep their current value.

## Usage

``` r
geolibre_fly_to(
  proxy,
  center = NULL,
  zoom = NULL,
  bearing = NULL,
  pitch = NULL,
  duration = NULL,
  request_id = NULL
)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- center:

  Optional `c(longitude, latitude)` target.

- zoom:

  Optional target zoom level.

- bearing:

  Optional target bearing in degrees.

- pitch:

  Optional target pitch in degrees.

- duration:

  Optional animation duration in milliseconds.

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_fly_to(geolibre_proxy("map"), center = c(-77.0369, 38.9072), zoom = 12)
}
```
