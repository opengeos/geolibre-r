# Zoom a live GeoLibre map to a layer's extent

Zoom a live GeoLibre map to a layer's extent

## Usage

``` r
geolibre_zoom_to_layer(proxy, layer_id, request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- layer_id:

  The layer's id, as reported by
  [`get_layers()`](https://r.geolibre.app/reference/get_layers.md).

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_zoom_to_layer(geolibre_proxy("map"), "layer-id")
}
```
