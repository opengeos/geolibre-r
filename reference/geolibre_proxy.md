# Create a GeoLibre Shiny proxy

Create a GeoLibre Shiny proxy

## Usage

``` r
geolibre_proxy(outputId, session = NULL)
```

## Arguments

- outputId:

  ID of an existing GeoLibre widget.

- session:

  A Shiny session.

## Value

A proxy object.

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  proxy <- geolibre_proxy("map")
}
```
