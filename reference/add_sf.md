# Add an `sf` object to a GeoLibre map

The object is transformed to EPSG:4326 before serialization. An object
with no CRS is taken to be in longitude/latitude order already, since
that is what GeoJSON means.

## Usage

``` r
add_sf(
  map,
  data,
  name = NULL,
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- data:

  An `sf`, `sfc`, or `sfg` object.

- name:

  Layer name. Defaults to the expression passed as `data`.

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
if (requireNamespace("sf", quietly = TRUE)) {
  point <- sf::st_sf(
    name = "Washington, DC",
    geometry = sf::st_sfc(sf::st_point(c(-77.0369, 38.9072)), crs = 4326)
  )
  map <- geolibre() |> add_sf(point, name = "Places")
}
```
