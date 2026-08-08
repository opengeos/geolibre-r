# Add a point density heatmap

Add a point density heatmap

## Usage

``` r
add_heatmap(
  map,
  points,
  name = "Heatmap",
  radius = 30,
  intensity = 1,
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

  Heatmap kernel radius in pixels.

- intensity:

  Heatmap intensity multiplier.

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
  add_heatmap(list(c(-77, 39), c(-77.05, 39.02)), radius = 40)
stopifnot(map$x$project$layers[[1]]$style$pointRenderer == "heatmap")
```
