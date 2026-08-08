# Set the GeoLibre camera

Set the GeoLibre camera

## Usage

``` r
set_view(
  map,
  center = NULL,
  zoom = NULL,
  bearing = NULL,
  pitch = NULL,
  bbox = NULL
)
```

## Arguments

- map:

  A GeoLibre widget.

- center:

  Optional longitude/latitude pair.

- zoom, bearing, pitch:

  Optional camera values.

- bbox:

  Optional west/south/east/north bounds. When supplied it takes
  precedence over `center` and `zoom`.

## Value

The modified widget.
