# Add GeoJSON to a GeoLibre map

Add GeoJSON to a GeoLibre map

## Usage

``` r
add_geojson(
  map,
  data,
  name = "GeoJSON",
  style = list(),
  visible = TRUE,
  opacity = 1
)
```

## Arguments

- map:

  A GeoLibre widget.

- data:

  A GeoJSON list, JSON string, file path, or an `sf` object.

- name:

  Layer name.

- style:

  Named list of GeoLibre style overrides such as `fillColor`,
  `strokeColor`, and `strokeWidth`.

- visible:

  Whether the layer is initially visible.

- opacity:

  Layer opacity from zero to one.

## Value

The modified widget.

## Examples

``` r
point <- list(
  type = "Feature",
  properties = list(name = "Washington, DC"),
  geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
)
map <- geolibre() |> add_geojson(point, name = "Places")
stopifnot(length(map$x$project$layers) == 1L)
```
