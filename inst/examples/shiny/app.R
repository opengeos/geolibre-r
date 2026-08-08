library(shiny)
library(geolibre)

point <- list(
  type = "FeatureCollection",
  features = list(list(
    type = "Feature",
    properties = list(name = "Washington, DC"),
    geometry = list(type = "Point", coordinates = c(-77.0369, 38.9072))
  ))
)

initial_map <- geolibre(map_only = TRUE) |>
  add_geojson(point, "Washington, DC") |>
  set_view(center = c(-77.0369, 38.9072), zoom = 9)

ui <- fluidPage(
  titlePanel("GeoLibre for Shiny"),
  actionButton("reset", "Reset view"),
  geolibreOutput("map", height = "75vh")
)

server <- function(input, output, session) {
  output$map <- renderGeolibre(initial_map)
  observeEvent(input$reset, {
    update_geolibre(
      geolibre_proxy("map"),
      set_view(initial_map, center = c(0, 20), zoom = 2)
    )
  })
}

shinyApp(ui, server)
