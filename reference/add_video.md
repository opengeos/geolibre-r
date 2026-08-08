# Add a georeferenced video layer

Add a georeferenced video layer

## Usage

``` r
add_video(
  map,
  urls,
  coordinates,
  name = "Video",
  style = list(),
  visible = TRUE,
  opacity = 1,
  ...
)
```

## Arguments

- map:

  A GeoLibre widget.

- urls:

  One video URL, or several as format fallbacks such as MP4 then WebM.
  URLs must be `https://`, since the browser's media policy blocks plain
  HTTP.

- coordinates:

  Four `c(longitude, latitude)` corners in top-left, top-right,
  bottom-right, bottom-left order, given as a list of pairs or a
  four-row matrix.

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
map <- geolibre() |>
  add_video(
    "https://example.com/clip.mp4",
    coordinates = list(
      c(-77.1, 39.0), c(-77.0, 39.0), c(-77.0, 38.9), c(-77.1, 38.9)
    )
  )
stopifnot(map$x$project$layers[[1]]$type == "video")
```
