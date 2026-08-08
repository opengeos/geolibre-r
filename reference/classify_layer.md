# Symbolize an existing layer as a choropleth

Symbolize an existing layer as a choropleth

## Usage

``` r
classify_layer(
  map,
  layer,
  column,
  class_count = 5,
  colormap = "viridis",
  scheme = c("equal-interval", "quantile")
)
```

## Arguments

- map:

  A GeoLibre widget.

- layer:

  A layer id or layer name. The layer must carry inlined GeoJSON.

- column:

  Name of the numeric feature property to classify.

- class_count:

  Number of classes, clamped to between 2 and 12.

- colormap:

  A color ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).

- scheme:

  Classification scheme, `"equal-interval"` or `"quantile"`.

## Value

The modified widget.

## See also

[`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md)
to add and symbolize in one call.

## Examples

``` r
counties <- list(
  type = "FeatureCollection",
  features = list(
    list(
      type = "Feature", properties = list(pop = 10),
      geometry = list(type = "Point", coordinates = c(-77, 39))
    ),
    list(
      type = "Feature", properties = list(pop = 90),
      geometry = list(type = "Point", coordinates = c(-76, 40))
    )
  )
)
map <- geolibre() |>
  add_geojson(counties, name = "Counties") |>
  classify_layer("Counties", "pop", colormap = "reds")
stopifnot(map$x$project$layers[[1]]$style$vectorStyleProperty == "pop")
```
