# Read a GeoLibre project

Read a GeoLibre project

## Usage

``` r
load_project(source)
```

## Arguments

- source:

  Path to a `.geolibre.json` file or a JSON string.

## Value

A project list.

## See also

[`save_project()`](https://r.geolibre.app/reference/save_project.md),
[`describe_project()`](https://r.geolibre.app/reference/describe_project.md)

## Examples

``` r
project <- load_project('{"version":"0.2.0","name":"Example","mapView":{}}')
stopifnot(project$name == "Example")

# A saved project can be reopened as a widget.
path <- tempfile(fileext = ".geolibre.json")
save_project(geolibre() |> add_marker(-77, 39), path)
map <- geolibre(load_project(path))
```
