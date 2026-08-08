# Strip credentials from a whole project

Returns a project safe to publish, export, or hand to someone else:
layer request headers and signed URLs, basemap style keys, geocoding
keys, stored environment variables, and third-party plugin settings are
all removed. The first-party map controls (legend, colorbar, swipe) are
kept, since a project needs them to render as it was built.

## Usage

``` r
redact_credentials(project)
```

## Arguments

- project:

  A GeoLibre widget or a project list.

## Value

The project list with credentials removed.

## Details

[`save_project()`](https://r.geolibre.app/reference/save_project.md)
applies this by default.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39)
safe <- redact_credentials(map)
safe$name
#> [1] "Untitled Project"
```
