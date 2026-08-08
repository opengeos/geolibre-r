# Add a CSV of point coordinates

[`add_xy_data()`](https://r.geolibre.app/reference/add_xy_data.md) with
a CSV-oriented default layer name.

## Usage

``` r
add_csv(
  map,
  data,
  x = "longitude",
  y = "latitude",
  name = "CSV",
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

  A data frame, a CSV file path, a CSV URL, CSV text, or a list of row
  lists.

- x:

  Name of the longitude column.

- y:

  Name of the latitude column.

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

## Examples

``` r
text <- "name,longitude,latitude\nDC,-77.0369,38.9072"
map <- geolibre() |> add_csv(text)
```
