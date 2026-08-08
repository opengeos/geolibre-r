# Shiny bindings for GeoLibre

Shiny bindings for GeoLibre

## Usage

``` r
geolibreOutput(outputId, width = "100%", height = "700px")

renderGeolibre(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  Output variable to read from.

- width, height:

  Widget dimensions.

- expr:

  An expression that generates a GeoLibre widget.

- env:

  Environment in which to evaluate `expr`.

- quoted:

  Whether `expr` is quoted.

## Value

`geolibreOutput()` returns a Shiny output element; `renderGeolibre()`
returns a render function for it.

## Shiny inputs

A rendered widget reports back through four inputs, where `id` is the
`outputId`:

- `input$id_project` — the full project each time the user edits the
  map.

- `input$id_error` — the message from a project the application
  rejected.

- `input$id_result` — the reply to a proxy command; a list with
  `requestId`, `method`, `ok`, and then `value` or `error`.

- `input$id_event` — user interaction; a list with `event`, one of
  `"click"`, `"selection-change"`, or `"layer-change"`, and its
  `payload`.

## Examples

``` r
if (requireNamespace("shiny", quietly = TRUE)) {
  output <- geolibreOutput("map", height = "500px")
  stopifnot(inherits(output, "shiny.tag.list"))
}
```
