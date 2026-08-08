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

## Examples

``` r
project <- load_project('{"version":"0.2.0","name":"Example","mapView":{}}')
stopifnot(project$name == "Example")
```
