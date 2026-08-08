# Run a processing algorithm on a live GeoLibre map

`geolibre_list_algorithms()` reports the available tools with their
parameters; `geolibre_run_algorithm()` runs one in the browser. Results
arrive on `input$id_result`, and any output layers are added to the map.

## Usage

``` r
geolibre_run_algorithm(proxy, algorithm, params = list(), request_id = NULL)

geolibre_list_algorithms(proxy, request_id = NULL)
```

## Arguments

- proxy:

  A GeoLibre proxy created by
  [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md).

- algorithm:

  The algorithm id, as reported by `geolibre_list_algorithms()`.

- params:

  Named list of algorithm parameters.

- request_id:

  Optional id echoed back with the reply.

## Value

The proxy, invisibly.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  proxy <- geolibre_proxy("map")
  geolibre_list_algorithms(proxy)
  geolibre_run_algorithm(proxy, "buffer", list(layerId = "abc", distance = 500))
}
```
