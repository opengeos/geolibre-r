# Identify features at a point on a live GeoLibre map

Identify features at a point on a live GeoLibre map

## Usage

``` r
geolibre_identify(proxy, lnglat, layer_id = NULL, request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- lnglat:

  `c(longitude, latitude)` of the point to query.

- layer_id:

  Optional layer id to restrict the query to.

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_identify(geolibre_proxy("map"), c(-77.0369, 38.9072))
}
```
