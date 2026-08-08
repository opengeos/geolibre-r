# Regressions found in review of the API expansion. Each test names the wrong
# behaviour it pins down, since several turn on subtle R list semantics.

test_that("re-keying a duplicate does not graft a sourceId onto layers without one", {
  # `$` partial matches on a list, so `metadata$sourceId` used to resolve to the
  # `sourceIds` array a COG or vector layer carries, pass the guard, and then
  # create a `sourceId` field the source layer never had.
  vector_copy <- geolibre() |>
    add_geoparquet("https://example.com/a.parquet", name = "Parcels") |>
    duplicate_layer("Parcels")
  expect_false("sourceId" %in% names(vector_copy$x$project$layers[[2]]$metadata))

  cog_copy <- geolibre() |>
    add_raster("https://example.com/a.tif", name = "Image") |>
    duplicate_layer("Image")
  expect_false("sourceId" %in% names(cog_copy$x$project$layers[[2]]$metadata))

  # A layer that genuinely carries one is still re-keyed.
  pmtiles_copy <- geolibre() |>
    add_pmtiles("https://example.com/a.pmtiles", name = "Tiles") |>
    duplicate_layer("Tiles")
  copy <- pmtiles_copy$x$project$layers[[2]]
  expect_equal(copy$metadata$sourceId, copy$id)
  expect_equal(copy$source$sourceId, copy$id)
})

test_that("clear_layers leaves no swipe reference to a deleted layer", {
  map <- geolibre() |>
    add_raster("https://example.com/a.tif", name = "A") |>
    add_raster("https://example.com/b.tif", name = "B") |>
    split_map("A", c("B", "__basemap__")) |>
    clear_layers()
  swipe <- map$x$project$plugins$settings[["maplibre-gl-swipe"]]
  expect_length(swipe$leftLayers, 0L)
  # The basemap is a pseudo-id rather than a layer, so it survives.
  expect_equal(unlist(swipe$rightLayers), "__basemap__")
})

test_that("removing a layer with no id leaves both swipe sides alone", {
  # `ids != NULL` is logical(0), which used to select nothing and empty both
  # sides rather than neither.
  map <- geolibre() |>
    add_raster("https://example.com/a.tif", name = "A") |>
    add_raster("https://example.com/b.tif", name = "B") |>
    split_map("A", "B")
  trimmed <- drop_swipe_reference(map$x$project, NULL)
  swipe <- trimmed$plugins$settings[["maplibre-gl-swipe"]]
  expect_length(swipe$leftLayers, 1L)
  expect_length(swipe$rightLayers, 1L)
})

test_that("a malformed layer entry cannot desynchronize layer positions", {
  project <- geolibre()$x$project
  project$layers <- list(
    NULL,
    list(id = "i1", name = "Pin", type = "geojson", visible = TRUE, opacity = 1)
  )
  map <- geolibre(project)
  # normalize_project drops the entry, so positions line up everywhere.
  expect_length(map$x$project$layers, 1L)
  expect_equal(layer_names(map), "Pin")
  expect_false(hide_layer(map, "Pin")$x$project$layers[[1]]$visible)

  # And the resolver still reports a raw-list position if one slips past.
  unnormalized <- geolibre()
  unnormalized$x$project$layers <- list(NULL, list(id = "i2", name = "Q", type = "geojson"))
  expect_equal(find_layer_position(unnormalized$x$project, "Q"), 2L)
})

test_that("a NULL style override is ignored rather than written as JSON null", {
  # Writing null would override the application's own default for the key.
  missing_color <- NULL
  layer <- add_geojson(
    geolibre(), list(type = "Point", coordinates = c(0, 0)),
    fillColor = missing_color
  )$x$project$layers[[1]]
  expect_equal(layer$style$fillColor, "#3b82f6")
  restyled <- geolibre() |>
    add_marker(-77, 39, name = "Pin") |>
    set_layer_style("Pin", fillColor = NULL, strokeWidth = 4)
  expect_equal(restyled$x$project$layers[[1]]$style$fillColor, "#3b82f6")
  expect_equal(restyled$x$project$layers[[1]]$style$strokeWidth, 4)
})

test_that("add_xy_data keeps columns that merely share a coordinate alias name", {
  # The marker coercion strips every alias it recognizes, which used to discard
  # a projected x/y pair carried alongside the chosen lon/lat columns.
  frame <- data.frame(
    name = "a", longitude = -77, latitude = 39, x = 123, y = 456,
    stringsAsFactors = FALSE
  )
  properties <- add_xy_data(geolibre(), frame)$x$project$layers[[1]]$geojson$features[[1]]$properties
  expect_named(properties, c("name", "x", "y"))
  expect_equal(properties$x, 123)
  # The chosen coordinate columns are still consumed, not duplicated.
  expect_false("longitude" %in% names(properties))
})

test_that("a video layer reports its source URL in a summary", {
  # `$url` partial matched the `urls` array and yielded a list, so the summary
  # reported NA for every video layer.
  map <- add_video(
    geolibre(), "https://example.com/clip.mp4",
    list(c(-77.1, 39), c(-77, 39), c(-77, 38.9), c(-77.1, 38.9))
  )
  expect_equal(get_layers(map)$source, "https://example.com/clip.mp4")
})
