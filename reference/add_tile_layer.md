# Add an XYZ raster tile layer

Add an XYZ raster tile layer

## Usage

``` r
add_tile_layer(
  map,
  url,
  name = "Tile Layer",
  tile_size = 256,
  attribution = NULL,
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- url:

  An XYZ tile URL template containing `{z}`, `{x}`, and `{y}`.

- name:

  Layer name.

- tile_size:

  Tile size in pixels, typically 256.

- attribution:

  Optional attribution string.

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
  add_tile_layer(
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    name = "OpenStreetMap",
    attribution = "OpenStreetMap contributors"
  )
stopifnot(map$x$project$layers[[1]]$type == "xyz")
```
