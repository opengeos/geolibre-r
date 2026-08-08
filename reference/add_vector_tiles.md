# Add a vector tile layer from a TileJSON endpoint

Add a vector tile layer from a TileJSON endpoint

## Usage

``` r
add_vector_tiles(
  map,
  url,
  name = "Vector Tiles",
  source_layers = NULL,
  source_layer = NULL,
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

  TileJSON endpoint for the vector tileset.

- name:

  Layer name.

- source_layers:

  Source layer names to render, for multi-layer tilesets.

- source_layer:

  A single source layer name, for the common single-layer case. Ignored
  when `source_layers` is supplied.

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
  add_vector_tiles("https://example.com/tiles.json", source_layer = "roads")
stopifnot(map$x$project$layers[[1]]$type == "vector-tiles")
```
