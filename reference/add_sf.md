# Add an `sf` object to a GeoLibre map

The object is transformed to EPSG:4326 before serialization.

## Usage

``` r
add_sf(
  map,
  data,
  name = deparse(substitute(data)),
  style = list(),
  visible = TRUE,
  opacity = 1
)
```

## Arguments

- map:

  A GeoLibre widget.

- data:

  An `sf` or `sfc` object.

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
