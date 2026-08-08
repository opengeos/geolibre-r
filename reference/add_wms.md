# Add a WMS layer

The layer is rendered as tiled raster from WMS `GetMap` requests, built
exactly as the application's Add Data dialog builds them.

## Usage

``` r
add_wms(
  map,
  endpoint,
  layers,
  name = "WMS Layer",
  styles = "",
  image_format = "image/png",
  transparent = TRUE,
  tile_size = 256,
  version = "1.1.1",
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- endpoint:

  WMS service endpoint, the `GetMap` base URL.

- layers:

  Comma-separated WMS layer name(s).

- name:

  Layer name.

- styles:

  Comma-separated WMS style name(s); empty for the server default.

- image_format:

  WMS image format, for example `"image/png"`.

- transparent:

  Whether to request transparent tiles.

- tile_size:

  Tile size in pixels.

- version:

  WMS protocol version, `"1.1.1"` or `"1.3.0"`. Version 1.3.0 sends
  `CRS` instead of `SRS`; some servers accept only one version.

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
  add_wms(
    "https://example.com/geoserver/wms",
    layers = "topp:states",
    name = "States"
  )
stopifnot(map$x$project$layers[[1]]$type == "wms")
```
