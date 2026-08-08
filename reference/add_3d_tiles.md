# Add a 3D Tiles layer

Add a 3D Tiles layer

## Usage

``` r
add_3d_tiles(
  map,
  url,
  name = "3D Tiles",
  altitude_offset = 0,
  request_headers = NULL,
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

  URL of the 3D Tiles `tileset.json`.

- name:

  Layer name.

- altitude_offset:

  Vertical offset applied to the tileset, in meters.

- request_headers:

  Optional named list of request headers. These are stored in the
  project, so avoid persisting secrets;
  [`save_project()`](https://r.geolibre.app/reference/save_project.md)
  strips them unless `keep_credentials = TRUE`.

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
  add_3d_tiles("https://example.com/tileset.json", altitude_offset = 20)
stopifnot(map$x$project$layers[[1]]$type == "3d-tiles")
```
