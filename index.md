# geolibre

[![R-CMD-check](https://github.com/opengeos/geolibre-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/opengeos/geolibre-r/actions/workflows/R-CMD-check.yaml)
[![GeoLibre](https://img.shields.io/badge/GeoLibre-web-16a34a)](https://web.geolibre.app/)

`geolibre` brings the full [GeoLibre](https://geolibre.app/) GIS
application to RStudio, Quarto, R Markdown, and Shiny. It is an
`htmlwidgets` interface to GeoLibre’s project format and embed bridge.

## Installation

``` r

# install.packages("pak")
pak::pak("opengeos/geolibre-r")
```

## Quick start

``` r

library(geolibre)

points <- list(
  type = "FeatureCollection",
  features = list(list(
    type = "Feature",
    properties = list(name = "Washington, DC"),
    geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
  ))
)

geolibre(map_only = TRUE) |>
  add_geojson(
    points,
    name = "Places",
    style = list(fillColor = "#dc2626", circleRadius = 8)
  ) |>
  set_view(center = c(-77.0369, 38.9072), zoom = 10)
```

### `sf`

[`add_sf()`](https://opengeos.github.io/geolibre-r/reference/add_sf.md)
transforms data to WGS 84 before sending GeoJSON to the browser.

``` r

library(sf)

nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

geolibre() |>
  add_sf(nc, "North Carolina counties")
```

### Remote rasters

Remote Cloud Optimized GeoTIFFs are read directly by GeoLibre in the
browser. The server must support CORS and HTTP range requests.

``` r

geolibre() |>
  add_raster(
    "https://example.org/visual.tif",
    name = "Satellite image",
    bands = c(1, 2, 3)
  )
```

### Project files

``` r

map <- geolibre() |> add_geojson(points)
save_project(map, "example.geolibre.json")

restored <- geolibre(load_project("example.geolibre.json"))
```

The saved file uses GeoLibre’s portable `.geolibre.json` format and can
be opened in the web or desktop application.
[`save_project()`](https://opengeos.github.io/geolibre-r/reference/save_project.md)
saves the state held by the R widget. In Shiny, browser-side changes are
also available as `input$<outputId>_project`.

## Shiny

``` r

library(shiny)
library(geolibre)

ui <- fluidPage(
  geolibreOutput("map", height = "80vh"),
  actionButton("reset", "Reset view")
)

server <- function(input, output, session) {
  map <- reactiveVal(geolibre(map_only = TRUE))
  output$map <- renderGeolibre(map())

  observeEvent(input$reset, {
    next_map <- set_view(map(), center = c(0, 20), zoom = 2)
    map(next_map)
    update_geolibre(geolibre_proxy("map"), next_map)
  })

  observeEvent(input$map_project, {
    message("GeoLibre now has ", length(input$map_project$layers), " layers")
  })
}

shinyApp(ui, server)
```

## Self-hosted GeoLibre

Use `app_url` per widget or set a session-wide option:

``` r

options(geolibre.app_url = "https://gis.example.org/")
```

The deployment must expose the GeoLibre web app and support its
`?embed=1` project bridge.

## Current scope

- GeoJSON and `sf` vector layers
- Remote COG/GeoTIFF raster layers
- Camera control
- GeoLibre project import and export
- R Markdown, Quarto, RStudio Viewer, and Shiny support
- Configurable hosted or self-hosted GeoLibre application

The package intentionally does not bundle GeoLibre’s large web
distribution. This keeps the R package small and lets maps use the
latest compatible hosted application. Offline bundling can be added as
an optional distribution later.
