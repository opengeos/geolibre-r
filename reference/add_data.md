# Add data, optionally symbolized by a column

With `column` supplied this is
[`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md);
without it,
[`add_geojson()`](https://r.geolibre.app/reference/add_geojson.md).
Provided for parity with the Python API.

## Usage

``` r
add_data(map, data, column = NULL, name = "Data", ...)
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

- column:

  Optional numeric property to drive graduated symbology.

- name:

  Layer name.

- ...:

  Forwarded to
  [`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md)
  or [`add_geojson()`](https://r.geolibre.app/reference/add_geojson.md).

## Value

The modified widget.

## Examples

``` r
point <- list(type = "Point", coordinates = c(-77, 39))
map <- geolibre() |> add_data(point, name = "Point")
```
