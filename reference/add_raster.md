# Add a remote raster to a GeoLibre map

[`add_cog()`](https://r.geolibre.app/reference/add_cog.md) with a
generic default layer name.

## Usage

``` r
add_raster(
  map,
  url,
  name = "Raster",
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

## Examples

``` r
map <- geolibre() |>
  add_raster("https://example.com/image.tif", bands = c(1, 2, 3))
stopifnot(map$x$project$layers[[1]]$type == "cog")
```
