# Summarize a GeoLibre project

Reports the camera, basemap, layers, and active map controls. URLs come
back with their credentials stripped, since several basemap providers
put an API key in the style URL itself.

## Usage

``` r
describe_project(project)
```

## Arguments

- project:

  A GeoLibre widget or a project list.

## Value

A list with the project `name`, `version`, `mapView`, `basemapStyleUrl`,
`layerCount`, a `layers` data frame, and the names of the active
`mapControls`.

## See also

[`get_layers()`](https://r.geolibre.app/reference/get_layers.md)

## Examples

``` r
map <- geolibre() |>
  add_marker(-77, 39, name = "Pin") |>
  add_legend(legend = c(Pin = "#3b82f6"))
summary <- describe_project(map)
summary$layerCount
#> [1] 1
summary$mapControls
#> [1] "legend"
```
