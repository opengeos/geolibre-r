# Add a single point marker

Add a single point marker

## Usage

``` r
add_marker(
  map,
  lng,
  lat,
  name = "Marker",
  properties = NULL,
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- lng:

  Marker longitude.

- lat:

  Marker latitude.

- name:

  Layer name.

- properties:

  Optional named list of feature properties, shown when the point is
  clicked.

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
  add_marker(-77.0369, 38.9072, name = "DC", circleRadius = 10)
```
