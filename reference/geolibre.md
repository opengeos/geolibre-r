# Create a GeoLibre widget

Creates an `htmlwidget` that embeds the GeoLibre geographic information
system. The widget carries a `.geolibre.json` project, which the
`add_*()`, `set_*()`, and control functions build up with the pipe.

## Usage

``` r
geolibre(
  project = NULL,
  center = NULL,
  zoom = NULL,
  basemap = NULL,
  name = "Untitled Project",
  width = NULL,
  height = NULL,
  app_url = getOption("geolibre.app_url", "https://web.geolibre.app/"),
  layout = c("embed", "full", "maponly"),
  theme = c("light", "dark"),
  map_only = FALSE,
  elementId = NULL
)
```

## Arguments

- project:

  A GeoLibre project list, a path to a `.geolibre.json` file, or `NULL`
  for a new project.

- center:

  Optional initial `c(longitude, latitude)` map center.

- zoom:

  Optional initial zoom level.

- basemap:

  Optional basemap name from
  [`basemaps()`](https://r.geolibre.app/reference/basemaps.md) or a
  MapLibre style JSON URL. Ignored when `project` is supplied, which
  carries its own.

- name:

  Project name recorded in the project file.

- width, height:

  Widget dimensions passed to
  [`htmlwidgets::createWidget()`](https://rdrr.io/pkg/htmlwidgets/man/createWidget.html).

- app_url:

  URL of a GeoLibre web deployment. It must support the `?embed=1`
  project bridge.

- layout:

  Application chrome to show: `"embed"` (compact controls), `"full"`
  (the complete desktop interface), or `"maponly"` (map only).

- theme:

  Application theme, `"light"` or `"dark"`.

- map_only:

  Deprecated. `TRUE` is equivalent to `layout = "maponly"`.

- elementId:

  Optional widget element ID.

## Value

An `htmlwidget` that can be modified with `add_*()` functions.

## Details

The default hosted application requires internet access when the widget
is displayed. Package installation, project construction, and file
operations do not contact it. Set `app_url` or the `geolibre.app_url`
option to use a self-hosted deployment.

## See also

[`add_geojson()`](https://r.geolibre.app/reference/add_geojson.md),
[`set_view()`](https://r.geolibre.app/reference/set_view.md),
[`save_project()`](https://r.geolibre.app/reference/save_project.md)

## Examples

``` r
map <- geolibre(center = c(-77.0369, 38.9072), zoom = 10, layout = "maponly")
stopifnot(inherits(map, "geolibre"))

# A dark-themed map with the full application interface.
geolibre(basemap = "dark", layout = "full")

{"x":{"project":{"version":"0.2.0","name":"Untitled Project","mapView":{"center":[-100,40],"zoom":2,"bearing":0,"pitch":0},"basemapStyleUrl":"https://tiles.openfreemap.org/styles/dark","basemapVisible":true,"basemapOpacity":1,"layers":[],"styles":{},"preferences":{"map":{"restrictBounds":false,"bounds":[-180,-85,180,85],"minZoom":0,"maxZoom":24,"maxPitch":85,"renderWorldCopies":true},"environmentVariables":[]},"metadata":{}},"appUrl":"https://web.geolibre.app/","layout":"full","theme":"light"},"evals":[],"jsHooks":[]}
```
