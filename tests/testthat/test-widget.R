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
