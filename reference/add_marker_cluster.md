# Add clustered point markers

Builds a point layer with the cluster renderer enabled, so nearby points
collapse into count bubbles that split apart as the map zooms in.

## Usage

``` r
add_marker_cluster(
  map,
  points,
  name = "Marker Cluster",
  cluster_radius = 50,
  cluster_max_zoom = 14,
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

- cluster_radius:

  Cluster radius in pixels.

- cluster_max_zoom:

  Zoom level beyond which points are no longer clustered.

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
  add_marker_cluster(list(c(-77, 39), c(-77.1, 39.1)), cluster_radius = 60)
stopifnot(map$x$project$layers[[1]]$style$pointRenderer == "cluster")
```
