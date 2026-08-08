# Read the camera of a live GeoLibre map

The reply arrives on `input$id_result` with a `value` holding `center`,
`zoom`, `bearing`, `pitch`, and the current `bbox`.

## Usage

``` r
geolibre_get_view(proxy, request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_get_view(geolibre_proxy("map"))
}
```
