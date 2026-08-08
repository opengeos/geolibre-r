# Add point markers

Add point markers

## Usage

``` r
add_markers(
  map,
  points,
  name = "Markers",
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

## See also

[`add_circle_markers()`](https://r.geolibre.app/reference/add_circle_markers.md),
[`add_marker_cluster()`](https://r.geolibre.app/reference/add_marker_cluster.md),
[`add_heatmap()`](https://r.geolibre.app/reference/add_heatmap.md)

## Examples

``` r
map <- geolibre() |>
  add_markers(list(c(-77.0369, 38.9072), c(-74.006, 40.7128)), name = "Cities")
stopifnot(length(map$x$project$layers[[1]]$geojson$features) == 2L)
```
