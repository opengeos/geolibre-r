# Set the project name

Set the project name

## Usage

``` r
set_project_name(map, name)
```

## Arguments

- map:

  A GeoLibre widget.

- name:

  The project's display name, as shown in the application and stored in
  the project file.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |> set_project_name("Chesapeake Bay")
map$x$project$name
#> [1] "Chesapeake Bay"
```
