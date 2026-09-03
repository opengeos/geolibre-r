# geolibre

[![CRAN status](https://www.r-pkg.org/badges/version/geolibre)](https://CRAN.R-project.org/package=geolibre)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/geolibre)](https://CRAN.R-project.org/package=geolibre)
[![R-CMD-check](https://github.com/opengeos/geolibre-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/opengeos/geolibre-r/actions/workflows/R-CMD-check.yaml)
[![GeoLibre](https://img.shields.io/badge/GeoLibre-web-16a34a)](https://web.geolibre.app/)

`geolibre` brings the full [GeoLibre](https://geolibre.app/) GIS application to
RStudio, Quarto, R Markdown, and Shiny. It is an `htmlwidgets` interface to
GeoLibre's project format and embed bridge.

[Open the live interactive map example](https://r.geolibre.app/articles/interactive-map.html)
to try the R widget directly in your browser.

## Installation

Install the released version from
[CRAN](https://CRAN.R-project.org/package=geolibre):

```r
install.packages("geolibre")
```

Or the development version from GitHub:

```r
install.packages("pak")
pak::pak("opengeos/geolibre-r")
```

## Quick start

```r
library(geolibre)

points <- list(
  type = "FeatureCollection",
  features = list(list(
    type = "Feature",
    properties = list(name = "Washington, DC"),
    geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
  ))
)

geolibre(layout = "maponly") |>
  add_geojson(points, name = "Places", fillColor = "#dc2626", circleRadius = 8) |>
  set_view(center = c(-77.0369, 38.9072), zoom = 10)
```

Style overrides can be passed as named arguments, as above, or as a `style` list.
Every `add_*()`, `set_*()`, and control function takes the map first and returns
it, so calls compose with the pipe.

### `sf`

`add_sf()` transforms data to WGS 84 before sending GeoJSON to the browser.

```r
library(sf)

nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

geolibre() |>
  add_sf(nc, "North Carolina counties")
```

### Points, markers, and tables

```r
cities <- data.frame(
  name = c("Washington", "New York", "Boston"),
  longitude = c(-77.0369, -74.0060, -71.0589),
  latitude = c(38.9072, 40.7128, 42.3601)
)

geolibre() |>
  add_xy_data(cities, name = "Cities", circleRadius = 8) |>
  fit_bounds(c(-78, 38, -70, 43))
```

`add_markers()`, `add_circle_markers()`, `add_marker_cluster()`, and
`add_heatmap()` accept the same points in any of several shapes: a list of
`c(longitude, latitude)` pairs, a two-column matrix, a data frame, point
GeoJSON, or an `sf` object. `add_csv()` reads a path, a URL, or CSV text.

### Choropleths

`add_choropleth()` classifies a numeric column and colors it from a named ramp,
computing the same stops the application's Style panel does.

```r
geolibre() |>
  add_choropleth(nc, column = "BIR74", colormap = "blues", class_count = 6) |>
  add_legend("Births", legend = c(Low = "#eff6ff", High = "#1e3a8a"))
```

See `color_ramp_names()` for the available ramps and `basemaps()` for the named
basemap styles.

### Rasters, tiles, and services

Remote Cloud Optimized GeoTIFFs are read directly by GeoLibre in the browser.
The server must support CORS and HTTP range requests.

```r
geolibre() |>
  add_raster("https://example.org/visual.tif", name = "Satellite", bands = c(1, 2, 3)) |>
  add_tile_layer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", name = "OSM") |>
  add_wms("https://example.org/geoserver/wms", layers = "topp:states") |>
  add_pmtiles("https://example.org/buildings.pmtiles") |>
  add_3d_tiles("https://example.org/tileset.json")
```

`add_vector()` hands a URL to the application's in-browser vector control, so
GeoParquet, FlatGeobuf, zipped Shapefiles, and GeoPackages stream without being
inlined in the project. A local path is read with `sf` instead.

```r
geolibre() |> add_geoparquet("https://example.org/parcels.parquet")
```

### Managing layers

```r
map <- geolibre() |>
  add_raster("https://example.org/before.tif", name = "Before") |>
  add_raster("https://example.org/after.tif", name = "After")

get_layers(map)                      # one row per layer
map |>
  set_layer_opacity("Before", 0.6) |>
  move_layer("After", 1) |>
  split_map("Before", "After")       # a swipe comparison slider
```

Layers are addressed by name or by id. `layer_properties()` and
`column_values()` read attributes back out of an inlined vector layer.

### Standalone HTML

`to_html()` writes a self-contained page that needs no running R session.

```r
to_html(map, "map.html", title = "Before and after")
```

### Project files

```r
map <- geolibre() |> add_geojson(points)
save_project(map, "example.geolibre.json")

restored <- geolibre(load_project("example.geolibre.json"))
```

The saved file uses GeoLibre's portable `.geolibre.json` format and can be
opened in the web or desktop application, or in the Python API. `save_project()`
saves the state held by the R widget and strips credentials such as layer request
headers and signed URLs; pass `keep_credentials = TRUE` for a trusted local file.
`describe_project()` summarizes a project without printing its inlined data. In
Shiny, browser-side changes are also available as `input$<outputId>_project`.

## Shiny

```r
library(shiny)
library(geolibre)

ui <- fluidPage(
  geolibreOutput("map", height = "80vh"),
  actionButton("reset", "Reset view")
)

server <- function(input, output, session) {
  map <- reactiveVal(geolibre(layout = "maponly"))
  output$map <- renderGeolibre(map())

  # Replace the whole project.
  observeEvent(input$reset, {
    next_map <- set_view(map(), center = c(0, 20), zoom = 2)
    map(next_map)
    update_geolibre(geolibre_proxy("map"), next_map)
  })

  # Or drive the map that is already on screen, without re-rendering it.
  observeEvent(input$fly, {
    geolibre_fly_to(geolibre_proxy("map"), center = c(-77.0369, 38.9072), zoom = 12)
  })

  observeEvent(input$map_project, {
    message("GeoLibre now has ", length(input$map_project$layers), " layers")
  })

  # Where a command's reply lands.
  observeEvent(input$map_result, {
    message(input$map_result$method, " -> ok = ", input$map_result$ok)
  })

  # Clicks, selection changes, and layer changes from the browser.
  observeEvent(input$map_event, {
    message("event: ", input$map_event$event)
  })
}

shinyApp(ui, server)
```

The proxy functions cover the things a project cannot express: `geolibre_fly_to()`,
`geolibre_fit_bounds()`, `geolibre_zoom_to_layer()`, `geolibre_get_view()`,
`geolibre_identify()`, `geolibre_layer_features()`, `geolibre_to_image()`, and
`geolibre_run_algorithm()` for the application's browser-side processing tools.
`geolibre_command()` forwards anything else the bridge implements.

## Self-hosted GeoLibre

Use `app_url` per widget or set a session-wide option:

```r
options(geolibre.app_url = "https://gis.example.org/")
```

The deployment must expose the GeoLibre web app and support its `?embed=1`
project bridge.

## Scope

- Vector layers from GeoJSON, `sf`, GeoParquet, FlatGeobuf, Shapefiles,
  GeoPackage, KML, and CSV or data frame coordinates
- Markers, circle markers, clusters, and heatmaps
- Rasters (COG/GeoTIFF), XYZ tiles, WMS, WMTS, WFS, vector tiles, PMTiles,
  3D Tiles, and georeferenced video
- Choropleth classification, layer styling, ordering, and inspection
- Legends, colorbars, and split-map comparisons
- Camera control, basemaps, and bounding-box fitting
- Project import and export, credential redaction, and standalone HTML export
- R Markdown, Quarto, RStudio Viewer, and Shiny support, with a proxy that drives
  the live map
- Configurable hosted or self-hosted GeoLibre application

The package intentionally does not bundle GeoLibre's large web distribution.
This keeps the R package small and lets maps use the latest compatible hosted
application. Offline bundling can be added as an optional distribution later.
