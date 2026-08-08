# Add a data-driven choropleth layer

Classifies `column` into `class_count` numeric ranges and colors each
range from `colormap`, producing the same graduated symbology the
application's Style panel builds from the interface.

## Usage

``` r
add_choropleth(
  map,
  data,
  column,
  name = "Choropleth",
  class_count = 5,
  colormap = "viridis",
  scheme = c("equal-interval", "quantile"),
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

- column:

  Name of the numeric feature property to classify.

- name:

  Layer name.

- class_count:

  Number of classes, clamped to between 2 and 12.

- colormap:

  A color ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).

- scheme:

  Classification scheme, `"equal-interval"` or `"quantile"`.

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

[`classify_layer()`](https://r.geolibre.app/reference/classify_layer.md)
to symbolize a layer that is already on the map.

## Examples

``` r
counties <- list(
  type = "FeatureCollection",
  features = list(
    list(
      type = "Feature", properties = list(pop = 100),
      geometry = list(type = "Point", coordinates = c(-77, 39))
    ),
    list(
      type = "Feature", properties = list(pop = 900),
      geometry = list(type = "Point", coordinates = c(-76, 40))
    )
  )
)
map <- geolibre() |>
  add_choropleth(counties, column = "pop", colormap = "blues", class_count = 3)
stopifnot(map$x$project$layers[[1]]$style$vectorStyleMode == "graduated")
```
