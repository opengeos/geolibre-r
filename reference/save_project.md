# Save a GeoLibre project

Save a GeoLibre project

## Usage

``` r
save_project(map, path)
```

## Arguments

- map:

  A GeoLibre widget or project list.

- path:

  Output path, conventionally ending in `.geolibre.json`.

## Value

`path`, invisibly.

## Examples

``` r
path <- tempfile(fileext = ".geolibre.json")
save_project(geolibre(), path)
project <- load_project(path)
stopifnot(project$name == "Untitled Project")
```
