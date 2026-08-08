# Add a WFS layer

The `GetFeature` response is fetched and inlined into the project, so
the endpoint must be able to return GeoJSON. This function contacts the
service when called.

## Usage

``` r
add_wfs(
  map,
  endpoint,
  type_name,
  name = "WFS Layer",
  version = "2.0.0",
  output_format = "application/json",
  srs_name = "EPSG:4326",
  max_features = 1000,
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

  WFS service endpoint.

- type_name:

  WFS feature type name, for example `"topp:states"`.

- name:

  Layer name.

- version:

  WFS protocol version, for example `"2.0.0"` or `"1.1.0"`.

- output_format:

  Requested output format; must yield GeoJSON.

- srs_name:

  Spatial reference of the response.

- max_features:

  Cap on the number of returned features, since the response is inlined.
  Pass `NULL` to request every feature.

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
if (FALSE) { # \dontrun{
geolibre() |>
  add_wfs("https://ahocevar.com/geoserver/wfs", type_name = "topp:states")
} # }
```
