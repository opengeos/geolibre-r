# Create a GeoLibre widget

Create a GeoLibre widget

## Usage

``` r
geolibre(
  project = NULL,
  width = NULL,
  height = NULL,
  app_url = getOption("geolibre.app_url", "https://web.geolibre.app/"),
  map_only = FALSE,
  elementId = NULL
)
```

## Arguments

- project:

  A GeoLibre project list, a path to a `.geolibre.json` file, or `NULL`
  for a new project.

- width, height:

  Widget dimensions passed to
  [`htmlwidgets::createWidget()`](https://rdrr.io/pkg/htmlwidgets/man/createWidget.html).

- app_url:

  URL of a GeoLibre web deployment. It must support the `?embed=1`
  project bridge.

- map_only:

  Hide the application chrome and show only the map.

- elementId:

  Optional widget element ID.

## Value

An `htmlwidget` that can be modified with `add_*()` functions.
