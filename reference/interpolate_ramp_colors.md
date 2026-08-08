# Sample a color ramp into evenly spaced colors

Mirrors the application's ramp interpolation, so a palette generated
here matches the one the Style panel would compute.

## Usage

``` r
interpolate_ramp_colors(name = "viridis", count = 5)
```

## Arguments

- name:

  A ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).

- count:

  Number of colors to produce.

## Value

A character vector of `count` `#rrggbb` colors.

## Examples

``` r
interpolate_ramp_colors("viridis", 5)
#> [1] "#440154" "#364e80" "#339084" "#67c364" "#fde725"
```
