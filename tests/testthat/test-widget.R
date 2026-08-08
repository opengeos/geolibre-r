test_that("geolibre creates a valid default project", {
  map <- geolibre()
  expect_s3_class(map, "geolibre")
  expect_equal(map$x$project$version, "0.2.0")
  expect_equal(map$x$project$layers, list())
  expect_null(map$height)
  expect_equal(map$sizingPolicy$defaultHeight, 700)
  expect_true(map$sizingPolicy$viewer$fill)
  expect_true(map$sizingPolicy$browser$fill)
})

test_that("GeoJSON and raster layers are appended", {
  point <- list(
    type = "FeatureCollection",
    features = list(list(
      type = "Feature", properties = list(name = "A"),
      geometry = list(type = "Point", coordinates = c(-77, 39))
    ))
  )
  map <- geolibre() |>
    add_geojson(point, "Point", style = list(fillColor = "#ff0000")) |>
    add_raster("https://example.com/image.tif", bands = c(1, 2, 3))
  expect_length(map$x$project$layers, 2)
  expect_equal(map$x$project$layers[[1]]$type, "geojson")
  expect_equal(map$x$project$layers[[2]]$metadata$rasterState$mode, "rgb")
})

test_that("features and geometries are normalized to feature collections", {
  feature <- list(
    type = "Feature", properties = list(name = "A"),
    geometry = list(type = "Point", coordinates = c(-77, 39))
  )
  feature_map <- add_geojson(geolibre(), feature)
  expect_equal(feature_map$x$project$layers[[1]]$geojson$type, "FeatureCollection")
  expect_length(feature_map$x$project$layers[[1]]$geojson$features, 1)

  geometry_map <- add_geojson(geolibre(), feature$geometry)
  expect_equal(geometry_map$x$project$layers[[1]]$geojson$features[[1]]$geometry$type, "Point")
  expect_error(add_geojson(geolibre(), list(type = "Invalid")), "Unsupported")
})

test_that("view and project JSON round trip", {
  map <- set_view(geolibre(), center = c(-76.5, 38.9), zoom = 9, pitch = 30)
  path <- tempfile(fileext = ".geolibre.json")
  save_project(map, path)
  restored <- load_project(path)
  expect_equal(restored$mapView$center, list(-76.5, 38.9))
  expect_equal(restored$mapView$zoom, 9)
  expect_equal(restored$mapView$pitch, 30)
})

test_that("invalid inputs fail early", {
  expect_error(add_raster(geolibre(), "local.tif"), "HTTP")
  expect_error(add_geojson(geolibre(), 1), "GeoJSON")
  expect_error(set_view(geolibre(), center = 1), "longitude")
  expect_error(add_raster(geolibre(), "https://example.com/a.tif", bands = c(0, 2)), "positive integer")
  expect_error(add_raster(geolibre(), "https://example.com/a.tif", bands = 1.5), "positive integer")
  expect_error(add_raster(geolibre(), "https://example.com/a.tif", rescale = list(c(10, 0))), "rescale")
  expect_error(add_raster(geolibre(), "https://example.com/a.tif", rescale = list(c(0, Inf))), "rescale")
  expect_error(set_view(geolibre(), center = c(NA, 0)), "finite")
  expect_error(set_view(geolibre(), bbox = c(0, 0, Inf, 1)), "finite")
  expect_error(set_view(geolibre(), zoom = c(1, 2)), "zoom")
  expect_error(set_view(geolibre(), bearing = NA_real_), "bearing")
  expect_error(set_view(geolibre(), pitch = "30"), "pitch")
  expect_error(geolibre(app_url = "not-a-url"), "HTTP")
  expect_error(geolibre(list(version = 1, name = "Bad", mapView = list())), "version")
  expect_error(geolibre(list(version = "0.2.0", name = "Bad", mapView = 1)), "mapView")
  expect_error(add_geojson(geolibre(), list(type = "FeatureCollection"), name = ""), "name")
  expect_error(add_geojson(geolibre(), list(type = "FeatureCollection"), style = "red"), "style")
  expect_error(add_geojson(geolibre(), list(type = "FeatureCollection"), visible = NA), "visible")
  expect_error(add_raster(geolibre(), NA_character_), "HTTP")
  expect_error(add_raster(geolibre(), "https://example.com/a.tif", colormap = 1), "colormap")
  expect_error(load_project("not JSON"), "neither")
  expect_error(save_project(geolibre(), ""), "path")
})

test_that("Shiny proxies send complete project updates", {
  skip_if_not_installed("shiny")
  messages <- new.env(parent = emptyenv())
  session <- list(
    ns = function(id) paste0("ns-", id),
    sendCustomMessage = function(type, message) {
      messages$type <- type
      messages$message <- message
    }
  )
  proxy <- geolibre_proxy("map", session = session)
  expect_equal(proxy$id, "ns-map")
  expect_invisible(update_geolibre(proxy, geolibre()))
  expect_equal(messages$type, "geolibre:update")
  expect_equal(messages$message$project$name, "Untitled Project")
})

test_that("sf objects become WGS84 GeoJSON", {
  skip_if_not_installed("sf")
  feature <- sf::st_sf(
    label = "DC",
    geometry = sf::st_sfc(sf::st_point(c(-77.0369, 38.9072)), crs = 4326)
  )
  map <- add_sf(geolibre(), feature, "Place")
  geojson <- map$x$project$layers[[1]]$geojson
  expect_equal(geojson$type, "FeatureCollection")
  expect_equal(geojson$features[[1]]$properties$label, "DC")
})
