# Add a remote raster to a GeoLibre map

Add a remote raster to a GeoLibre map

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
  opacity = 1
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

  Optional one-based band indices.

- colormap:

  Optional GeoLibre colormap name.

- rescale:

  Optional list of numeric `[min, max]` ranges.

- style:

  Named list of style overrides.

- visible:

  Whether the layer is visible.

- opacity:

  Layer opacity from zero to one.

## Value

The modified widget.
