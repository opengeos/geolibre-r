# Add a vector dataset from a URL or local file

A remote URL is handed to the application's in-browser vector control,
so any format it reads (GeoParquet, FlatGeobuf, zipped Shapefile,
GeoPackage, GeoJSON, KML, ...) streams without being inlined in the
project. A local file is read with `sf` and inlined as GeoJSON, since
the browser cannot reach a file on this machine.

## Usage

``` r
add_vector(
  map,
  data,
  name = "Vector",
  render_mode = c("geojson", "tiles"),
  data_format = NULL,
  source_layer = NULL,
  picker = NULL,
  ingest_mode = NULL,
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

  A dataset URL, a local file path, or an `sf` object.

- name:

  Layer name.

- render_mode:

  `"geojson"` to load into a GeoJSON source, or `"tiles"` to stream as
  vector tiles. Remote URLs only.

- data_format:

  Optional format hint for remote URLs, for example `"parquet"` or
  `"flatgeobuf"`. The control auto-detects when omitted.

- source_layer:

  Optional layer or table name inside a multi-layer container such as a
  GeoPackage.

- picker:

  Optional toggle for the control's feature-inspection popup.

- ingest_mode:

  Optional ingest strategy, `"table"` or `"stream"`.

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
  add_vector("https://example.com/data.parquet", name = "Parcels")
stopifnot(map$x$project$layers[[1]]$metadata$sourceKind == "maplibre-gl-vector")
```
