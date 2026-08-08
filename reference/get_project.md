# Read a project out of a widget

Read a project out of a widget

## Usage

``` r
get_project(map, keep_credentials = FALSE)
```

## Arguments

- map:

  A GeoLibre widget or project list.

- keep_credentials:

  Keep credential-bearing configuration. Defaults to `FALSE`, so the
  returned project is safe to print or serialize.

## Value

The project as a list.

## Examples

``` r
map <- geolibre() |> add_marker(-77, 39, name = "Pin")
project <- get_project(map)
project$layers[[1]]$name
#> [1] "Pin"
```
