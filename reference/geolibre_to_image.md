# Capture a live GeoLibre map as a PNG

The reply arrives on `input$id_result` with a `value` holding a
`data:image/png;base64,...` URL. Strip the prefix up to the comma and
pass the rest to
[`jsonlite::base64_dec()`](https://jeroen.r-universe.dev/jsonlite/reference/base64.html)
to recover the PNG bytes.

## Usage

``` r
geolibre_to_image(proxy, request_id = NULL)
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
  geolibre_to_image(geolibre_proxy("map"))
}
```
