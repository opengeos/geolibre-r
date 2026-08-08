# Add a Cloud Optimized GeoTIFF layer

Add a Cloud Optimized GeoTIFF layer

## Usage

``` r
add_cog(
  map,
  url,
  name = "COG",
  bands = NULL,
  colormap = NULL,
  rescale = NULL,
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

  Public HTTP(S) URL of a Cloud Optimized GeoTIFF or GeoTIFF.

- name:

  Layer name.

- bands:

  Optional one-based band indices. Three or more bands render as RGB;
  one renders as a single band, which `colormap` then colors.

- colormap:

  Optional GeoLibre colormap name for single-band rendering.

- rescale:

  Optional list of numeric `c(min, max)` ranges, one per rendered band.
  A single `c(min, max)` pair is accepted for the one-band case.

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

## See also

[`add_raster()`](https://r.geolibre.app/reference/add_raster.md),
[`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md),
[`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md)

## Examples

``` r
map <- geolibre() |>
  add_cog("https://example.com/image.tif", bands = c(1, 2, 3))
stopifnot(map$x$project$layers[[1]]$type == "cog")
```
