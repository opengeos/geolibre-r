# Add GeoJSON to a GeoLibre map

Add GeoJSON to a GeoLibre map

## Usage

``` r
add_geojson(
  map,
  data,
  name = "GeoJSON",
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

  GeoJSON as a parsed list (a `FeatureCollection`, `Feature`, or bare
  geometry), a JSON string, a file path, an HTTP(S) URL, or an `sf`
  object. A URL or file is read and inlined into the project, up to a 50
  MB limit; for larger datasets prefer
  [`add_vector()`](https://r.geolibre.app/reference/add_vector.md),
  which lets the browser stream the source.

- name:

  Layer name.

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

[`add_sf()`](https://r.geolibre.app/reference/add_sf.md),
[`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md),
[`add_vector()`](https://r.geolibre.app/reference/add_vector.md)

## Examples

``` r
point <- list(
  type = "Feature",
  properties = list(name = "Washington, DC"),
  geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
)
map <- geolibre() |> add_geojson(point, name = "Places", fillColor = "#dc2626")
stopifnot(length(map$x$project$layers) == 1L)
```
