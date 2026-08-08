# Add a WMTS layer

Add a WMTS layer

## Usage

``` r
add_wmts(
  map,
  url,
  name = "WMTS Layer",
  tile_size = 256,
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

  A WMTS tile URL template in WMTS REST `{z}/{y}/{x}` order, with the
  row before the column. This differs from the `{z}/{x}/{y}` templates
  [`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md)
  expects.

- name:

  Layer name.

- tile_size:

  Tile size in pixels.

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
  add_wmts("https://example.com/wmts/layer/{z}/{y}/{x}.png", name = "Imagery")
stopifnot(map$x$project$layers[[1]]$type == "wmts")
```
