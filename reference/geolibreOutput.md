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
