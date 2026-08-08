# Add a PMTiles layer

The application registers the `pmtiles://` protocol itself, so a plain
`https://` URL to the archive is what this expects.

## Usage

``` r
add_pmtiles(
  map,
  url,
  name = "PMTiles",
  tile_type = c("vector", "raster"),
  source_layers = NULL,
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

  URL of the `.pmtiles` archive.

- name:

  Layer name.

- tile_type:

  `"vector"` or `"raster"`.

- source_layers:

  Vector source layer names to render. Vector tiles only.

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
  add_pmtiles("https://example.com/data.pmtiles", source_layers = "buildings")
stopifnot(map$x$project$layers[[1]]$type == "pmtiles")
```
