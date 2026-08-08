# Read features from a live GeoLibre map

`geolibre_layer_features()` returns one layer's features,
`geolibre_selected_features()` the current selection, and
`geolibre_drawn_features()` whatever the user drew with the map's
editing tools. Each reply arrives on `input$id_result`.

## Usage

``` r
geolibre_layer_features(proxy, layer_id, request_id = NULL)

geolibre_selected_features(proxy, request_id = NULL)

geolibre_drawn_features(proxy, request_id = NULL)
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
  geolibre_drawn_features(geolibre_proxy("map"))
}
```
