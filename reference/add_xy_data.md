# Add points from tabular longitude and latitude columns

Add points from tabular longitude and latitude columns

## Usage

``` r
add_xy_data(
  map,
  data,
  x = "longitude",
  y = "latitude",
  name = "XY Data",
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
cities <- data.frame(
  name = c("Washington", "New York"),
  longitude = c(-77.0369, -74.006),
  latitude = c(38.9072, 40.7128)
)
map <- geolibre() |> add_xy_data(cities, name = "Cities")
stopifnot(length(map$x$project$layers[[1]]$geojson$features) == 2L)
```
