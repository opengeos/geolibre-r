# Interactive GeoLibre map

This page runs the same `geolibre` code used in RStudio, Quarto, R
Markdown, and Shiny. The widget below embeds the hosted GeoLibre
application, so viewing the live map requires JavaScript and internet
access.

``` r

library(geolibre)

point <- list(
  type = "Feature",
  properties = list(name = "Washington, DC"),
  geometry = list(
    type = "Point",
    coordinates = c(-77.0369, 38.9072)
  )
)

geolibre(map_only = TRUE, height = 600) |>
  add_geojson(
    point,
    name = "Washington, DC",
    style = list(fillColor = "#dc2626", circleRadius = 8)
  ) |>
  set_view(center = c(-77.0369, 38.9072), zoom = 10)
```

If the embedded application is unavailable, open [GeoLibre
Web](https://web.geolibre.app/) directly.
