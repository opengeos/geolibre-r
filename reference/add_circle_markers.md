# Add circle markers

[`add_markers()`](https://r.geolibre.app/reference/add_markers.md) with
the circle radius surfaced as a named argument.

## Usage

``` r
add_circle_markers(
  map,
  points,
  name = "Circle Markers",
  radius = NULL,
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- points:

  Points as a two-column matrix or a data frame of coordinates, a list
  of `c(longitude, latitude)` pairs or named `list(lng = , lat = , ...)`
  entries, a point GeoJSON source, or an `sf` object of points.

- name:

  Layer name.

- radius:

  Optional circle radius in pixels.

- style:

  Named list of GeoLibre style overrides such as `fillColor`,
  `strokeColor`, and `strokeWidth`.

- visible:

  Whether the layer is initially visible.

- opacity:

  Layer opacity from zero to one.

- ...:

  Additional style overrides given as named arguments, merged into
  `style`. `add_geojson(map, data, fillColor = "red")` and
  `add_geojson(map, data, style = list(fillColor = "red"))` are
  equivalent.

## Value

The modified widget.

## Examples

``` r
map <- geolibre() |>
  add_circle_markers(list(c(-77, 39)), radius = 12, fillColor = "#16a34a")
```
