# Fit a live GeoLibre map to a bounding box

Fit a live GeoLibre map to a bounding box

## Usage

``` r
geolibre_fit_bounds(proxy, bbox, request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- bbox:

  `c(west, south, east, north)` bounds.

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_fit_bounds(geolibre_proxy("map"), c(-125, 24, -66, 50))
}
```
