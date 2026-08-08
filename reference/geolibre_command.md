# Send a command to a live GeoLibre map

The escape hatch behind the `geolibre_*()` command functions: it
forwards any method the application's scripting bridge implements. The
reply arrives asynchronously on the `input$id_result` input described in
[`geolibreOutput()`](https://r.geolibre.app/reference/geolibreOutput.md).

## Usage

``` r
geolibre_command(proxy, method, params = list(), request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- method:

  The scripting method name, for example `"flyTo"` or `"toImage"`.

- params:

  Named list of parameters for the method.

- request_id:

  Optional id echoed back with the reply, so several in-flight commands
  can be told apart. Generated when omitted.

## Value

The proxy, invisibly.

## See also

[`geolibre_fly_to()`](https://r.geolibre.app/reference/geolibre_fly_to.md),
[`geolibre_get_view()`](https://r.geolibre.app/reference/geolibre_get_view.md),
[`geolibre_run_algorithm()`](https://r.geolibre.app/reference/geolibre_run_algorithm.md)

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  geolibre_command(geolibre_proxy("map"), "zoomToLayer", list(layerId = "abc"))
}
```
