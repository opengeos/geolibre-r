# Anchor colors of a color ramp

Anchor colors of a color ramp

## Usage

``` r
get_color_ramp(name = "viridis")
```

## Arguments

- name:

  A ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).
  An unknown name falls back to `"viridis"`, matching the application's
  own lookup.

## Value

A character vector of `#rrggbb` colors.

## Examples

``` r
get_color_ramp("viridis")
#> [1] "#440154" "#31688e" "#35b779" "#fde725"
get_color_ramp("blues")
#> [1] "#eff6ff" "#93c5fd" "#2563eb" "#1e3a8a"
```
