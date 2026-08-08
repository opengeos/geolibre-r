# Interactive GeoLibre map

This page runs the same `geolibre` code used in RStudio, Quarto, R
Markdown, and Shiny. The widgets below embed the hosted GeoLibre
application, so viewing the live maps requires JavaScript and internet
access.

``` r

library(geolibre)
```

## Load a GeoLibre project

A complete `.geolibre.json` project can be loaded from a URL and passed
to [`geolibre()`](https://r.geolibre.app/reference/geolibre.md). This
example opens a 3D map of New York City buildings and subway lines. The
project is fetched while this page is built, so the chunk reports the
error rather than failing the build if the host is unreachable.

``` r

project_url <- "https://assets.geolibre.app/projects/nyc-buildings.geolibre.json"
nyc_buildings <- jsonlite::read_json(project_url, simplifyVector = FALSE)

geolibre(nyc_buildings, panels = "collapsed")
```

## A single point

Style overrides can be passed as named arguments or through a `style`
list.

``` r

point <- list(
  type = "Feature",
  properties = list(name = "Washington, DC"),
  geometry = list(
    type = "Point",
    coordinates = c(-77.0369, 38.9072)
  )
)

geolibre(layout = "maponly", height = 600) |>
  add_geojson(point, name = "Washington, DC", fillColor = "#dc2626", circleRadius = 8) |>
  set_view(center = c(-77.0369, 38.9072), zoom = 10)
```

## Points from a data frame

[`add_xy_data()`](https://r.geolibre.app/reference/add_xy_data.md) reads
longitude and latitude columns and keeps the remaining columns as
feature properties, so they appear when a point is clicked.
[`fit_bounds()`](https://r.geolibre.app/reference/fit_bounds.md) frames
the result.

``` r

cities <- data.frame(
  name = c("Washington", "New York", "Boston", "Philadelphia"),
  population = c(689545, 8336817, 654776, 1603797),
  longitude = c(-77.0369, -74.0060, -71.0589, -75.1652),
  latitude = c(38.9072, 40.7128, 42.3601, 39.9526)
)

geolibre(layout = "maponly", height = 600, basemap = "positron") |>
  add_circle_markers(cities, name = "Cities", radius = 9, fillColor = "#2563eb") |>
  fit_bounds(c(-78, 38, -70, 43))
```

## A choropleth with a legend

[`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md)
classifies a numeric column and colors it from a named ramp, computing
the same graduated stops the application’s Style panel produces.
[`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md)
lists the ramps, and
[`interpolate_ramp_colors()`](https://r.geolibre.app/reference/interpolate_ramp_colors.md)
samples one so a legend can match the map.

``` r

color_ramp_names()
#>  [1] "viridis"  "plasma"   "inferno"  "magma"    "cividis"  "turbo"   
#>  [7] "spectral" "blues"    "greens"   "oranges"  "reds"     "purples" 
#> [13] "terrain"  "rdylgn"   "rdylbu"   "rdbu"     "coolwarm" "jet"     
#> [19] "greys"    "gray"
```

``` r

counties <- list(
  type = "FeatureCollection",
  features = list(
    list(
      type = "Feature",
      properties = list(name = "Low", value = 10),
      geometry = list(type = "Point", coordinates = c(-77.5, 38.5))
    ),
    list(
      type = "Feature",
      properties = list(name = "Middle", value = 55),
      geometry = list(type = "Point", coordinates = c(-77.0, 39.0))
    ),
    list(
      type = "Feature",
      properties = list(name = "High", value = 100),
      geometry = list(type = "Point", coordinates = c(-76.5, 39.5))
    )
  )
)

breaks <- interpolate_ramp_colors("blues", 3)

geolibre(layout = "maponly", height = 600) |>
  add_choropleth(
    counties,
    column = "value",
    name = "Observations",
    colormap = "blues",
    class_count = 3,
    circleRadius = 14
  ) |>
  add_legend(
    "Observations",
    labels = c("10", "55", "100"),
    colors = breaks,
    shape = "circle"
  ) |>
  set_view(center = c(-77, 39), zoom = 8)
```

## Rasters and a colorbar

A remote Cloud Optimized GeoTIFF is read directly by the browser, so the
server must support CORS and HTTP range requests.
[`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md)
labels a single-band raster’s value range.

``` r

geolibre(layout = "maponly", height = 600) |>
  add_raster(
    "https://opendata.digitalglobe.com/events/california-fire-2020/pre-event/2018-02-16/pine-gulch-fire20/1030010076004E00.tif",
    name = "Imagery",
    bands = c(1, 2, 3)
  ) |>
  add_colorbar(colormap = "terrain", vmin = 0, vmax = 3000, label = "Elevation", units = "m")
```

## Inspecting and rearranging layers

Every layer function addresses a layer by its name or its id.
[`get_layers()`](https://r.geolibre.app/reference/get_layers.md) returns
one row per layer.

``` r

map <- geolibre() |>
  add_marker(-77.0369, 38.9072, name = "Capital") |>
  add_tile_layer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", name = "OpenStreetMap")

get_layers(map)
#>                                     id          name    type visible opacity
#> 1 b6aaa1e2-03ff-4fb5-9fa0-cf0d2430e040       Capital geojson    TRUE       1
#> 2 921de0dd-3a42-4676-aad0-bd56af4b77cc OpenStreetMap     xyz    TRUE       1
#>                                           source features
#> 1                                           <NA>        1
#> 2 https://tile.openstreetmap.org/{z}/{x}/{y}.png       NA

map <- map |>
  move_layer("OpenStreetMap", 1) |>
  set_layer_opacity("OpenStreetMap", 0.5)

layer_names(map)
#> [1] "OpenStreetMap" "Capital"
```

[`describe_project()`](https://r.geolibre.app/reference/describe_project.md)
summarizes a project without printing its inlined data.

``` r

summary <- describe_project(map)
summary$layerCount
#> [1] 2
summary$mapView$zoom
#> [1] 2
```

## Saving and exporting

A project saves to GeoLibre’s portable `.geolibre.json` format, which
the web app, the desktop app, and the Python API all read.
[`to_html()`](https://r.geolibre.app/reference/to_html.md) writes a
standalone page that needs no running R session.

``` r

path <- file.path(tempdir(), "example.geolibre.json")
save_project(map, path)

restored <- geolibre(load_project(path))
layer_names(restored)
#> [1] "OpenStreetMap" "Capital"
```

``` r

html_path <- file.path(tempdir(), "example.html")
to_html(map, html_path, title = "Example map")
file.exists(html_path)
#> [1] TRUE
```

If the embedded application is unavailable, open [GeoLibre
Web](https://web.geolibre.app/) directly.
