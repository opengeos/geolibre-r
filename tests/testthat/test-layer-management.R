three_layer_map <- function() {
  geolibre() |>
    add_marker(-77, 39, name = "Bottom") |>
    add_marker(-76, 40, name = "Middle") |>
    add_marker(-75, 41, name = "Top")
}

test_that("layers can be listed, summarized, and located", {
  map <- three_layer_map()
  expect_equal(layer_names(map), c("Bottom", "Middle", "Top"))
  summary <- get_layers(map)
  expect_s3_class(summary, "data.frame")
  expect_equal(nrow(summary), 3L)
  expect_equal(summary$features, c(1L, 1L, 1L))
  expect_true(all(summary$visible))
  expect_equal(find_layer_index(map, "Middle"), 2L)
  expect_equal(find_layer_index(map, "Absent"), -1L)
  expect_equal(get_layer(map, "Top")$name, "Top")
  expect_equal(nrow(get_layers(geolibre())), 0L)
})

test_that("a layer resolves by id as well as by name", {
  map <- three_layer_map()
  id <- map$x$project$layers[[2]]$id
  expect_equal(get_layer(map, id)$name, "Middle")
  expect_error(remove_layer(map, "Nope"), "No layer matches")
})

test_that("an exact id match wins over a name that collides with it", {
  map <- three_layer_map()
  id <- map$x$project$layers[[3]]$id
  map <- rename_layer(map, "Bottom", id)
  expect_equal(get_layer(map, id)$name, "Top")
})

test_that("an ambiguous name is an error rather than an arbitrary pick", {
  map <- geolibre() |>
    add_marker(-77, 39, name = "Pin") |>
    add_marker(-76, 40, name = "Pin")
  expect_error(remove_layer(map, "Pin"), "2 layers are named")
  # A unique case-insensitive match still resolves.
  expect_equal(get_layer(three_layer_map(), "middle")$name, "Middle")
})

test_that("visibility, opacity, and style can be changed after the fact", {
  map <- three_layer_map() |>
    hide_layer("Top") |>
    set_layer_opacity("Middle", 0.25) |>
    set_layer_style("Bottom", fillColor = "#f59e0b", circleRadius = 9)
  expect_false(map$x$project$layers[[3]]$visible)
  expect_equal(map$x$project$layers[[2]]$opacity, 0.25)
  expect_equal(map$x$project$layers[[1]]$style$fillColor, "#f59e0b")
  # Unmentioned style keys keep their values.
  expect_equal(map$x$project$layers[[1]]$style$strokeWidth, 2)
  expect_true(show_layer(map, "Top")$x$project$layers[[3]]$visible)
  expect_error(set_layer_opacity(map, "Top", 2), "between 0 and 1")
})

test_that("layers can be reordered from either end", {
  map <- three_layer_map()
  expect_equal(layer_names(move_layer(map, "Top", 1)), c("Top", "Bottom", "Middle"))
  expect_equal(layer_names(move_layer(map, "Bottom", -1)), c("Middle", "Top", "Bottom"))
  # Out-of-range positions clamp instead of erroring.
  expect_equal(layer_names(move_layer(map, "Bottom", 99)), c("Middle", "Top", "Bottom"))
  expect_error(move_layer(map, "Top", 0), "non-zero")
  expect_error(move_layer(map, "Top", 1.5), "non-zero integer")
})

test_that("duplicating a layer re-keys the ids the application derives", {
  map <- geolibre() |>
    add_pmtiles("https://example.com/a.pmtiles", name = "Tiles") |>
    duplicate_layer("Tiles")
  original <- map$x$project$layers[[1]]
  copy <- map$x$project$layers[[2]]
  expect_equal(copy$name, "Tiles copy")
  expect_false(identical(copy$id, original$id))
  expect_equal(copy$source$sourceId, copy$id)
  expect_equal(copy$metadata$nativeLayerIds, list(copy$id))

  named <- duplicate_layer(three_layer_map(), "Top", name = "Copy")
  expect_equal(layer_names(named)[[4]], "Copy")
})

test_that("removing a layer drops it from a swipe comparison", {
  map <- three_layer_map() |> split_map(c("Bottom", "Middle"), "Top")
  swipe <- map$x$project$plugins$settings[["maplibre-gl-swipe"]]
  expect_length(swipe$leftLayers, 2L)
  trimmed <- remove_layer(map, "Bottom")
  expect_length(
    trimmed$x$project$plugins$settings[["maplibre-gl-swipe"]]$leftLayers,
    1L
  )
  expect_equal(nrow(get_layers(clear_layers(map))), 0L)
})

test_that("feature properties can be sampled and read back", {
  collection <- list(
    type = "FeatureCollection",
    features = list(
      list(
        type = "Feature", properties = list(pop = 10, name = "a"),
        geometry = list(type = "Point", coordinates = c(-77, 39))
      ),
      list(
        type = "Feature", properties = list(pop = 90, name = "b"),
        geometry = list(type = "Point", coordinates = c(-76, 40))
      )
    )
  )
  map <- add_geojson(geolibre(), collection, name = "Places")
  samples <- layer_properties(map, "Places")
  expect_named(samples, c("pop", "name"))
  expect_equal(unlist(samples$pop), c(10, 90))
  expect_equal(unlist(column_values(map, "Places", "pop")), c(10, 90))
  expect_error(column_values(map, "Places", "missing"), "not found")
  # A raster layer carries no inlined features to read.
  raster <- add_raster(geolibre(), "https://example.com/a.tif", name = "Image")
  expect_error(layer_properties(raster, "Image"), "no inlined GeoJSON")
})

test_that("classify_layer symbolizes a layer already on the map", {
  collection <- list(
    type = "FeatureCollection",
    features = lapply(c(1, 5, 9), function(value) {
      list(
        type = "Feature", properties = list(v = value),
        geometry = list(type = "Point", coordinates = c(-77, 39))
      )
    })
  )
  map <- geolibre() |>
    add_geojson(collection, name = "Points") |>
    classify_layer("Points", "v", class_count = 3, colormap = "reds", scheme = "quantile")
  style <- map$x$project$layers[[1]]$style
  expect_equal(style$vectorStyleClassificationScheme, "quantile")
  expect_equal(style$vectorStyleColorRamp, "reds")
  expect_length(style$vectorStyleStops, 3L)
})
