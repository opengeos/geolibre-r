# Create a GeoLibre Shiny proxy

A proxy addresses a widget that is already on screen, so a Shiny app can
replace its project with
[`update_geolibre()`](https://r.geolibre.app/reference/update_geolibre.md)
or drive the live map with the `geolibre_*()` command functions, without
re-rendering the widget.

## Usage

``` r
geolibre_proxy(outputId, session = NULL)
```

## Arguments

- outputId:

  ID of an existing GeoLibre widget.

- session:

  A Shiny session. Defaults to the current reactive domain.

## Value

A `geolibre_proxy` object.

## See also

[`update_geolibre()`](https://r.geolibre.app/reference/update_geolibre.md),
[`geolibre_fly_to()`](https://r.geolibre.app/reference/geolibre_fly_to.md),
[`geolibre_command()`](https://r.geolibre.app/reference/geolibre_command.md)

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  proxy <- geolibre_proxy("map")
}
```
