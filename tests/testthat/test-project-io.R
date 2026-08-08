test_that("a full project round trips through the file format", {
  map <- geolibre(center = c(-77, 39), zoom = 8, basemap = "dark", name = "Bay") |>
    add_marker(-77, 39, name = "Pin") |>
    add_raster("https://example.com/a.tif", name = "Image", bands = c(1, 2, 3)) |>
    add_legend(legend = c(Pin = "#3b82f6")) |>
    split_map("Pin", "Image")
  path <- tempfile(fileext = ".geolibre.json")
  save_project(map, path)
  restored <- load_project(path)
  expect_equal(restored$name, "Bay")
  expect_equal(restored$version, "0.2.0")
  expect_equal(restored$mapView$center, list(-77, 39))
  expect_length(restored$layers, 2L)
  # Arrays that hold one element must stay arrays through the round trip.
  expect_equal(restored$layers[[2]]$metadata$nativeLayerIds, list(restored$layers[[2]]$id))
  expect_true(is.list(restored$plugins$settings[["maplibre-gl-swipe"]]$leftLayers))
  expect_equal(describe_project(restored)$mapControls, c("swipe", "legend"))
  # A restored project loads straight back into a widget.
  expect_s3_class(geolibre(restored), "geolibre")
  expect_equal(layer_names(geolibre(path)), c("Pin", "Image"))
})

test_that("save_project creates parent directories and returns its path", {
  path <- file.path(tempfile(), "nested", "map.geolibre.json")
  expect_equal(save_project(geolibre(), path), path)
  expect_true(file.exists(path))
})

test_that("save_project overwrites an existing project atomically", {
  path <- tempfile(fileext = ".geolibre.json")
  save_project(geolibre(name = "First"), path)
  save_project(geolibre(name = "Second"), path)
  expect_equal(load_project(path)$name, "Second")
  # No temporary files are left beside the destination.
  expect_length(list.files(dirname(path), pattern = "^\\.geolibre"), 0L)
})

test_that("get_project and describe_project read a widget or a bare project", {
  map <- geolibre() |> add_marker(-77, 39, name = "Pin")
  expect_equal(get_project(map)$layers[[1]]$name, "Pin")
  expect_equal(describe_project(map)$layerCount, 1L)
  expect_equal(describe_project(map$x$project)$layerCount, 1L)
  expect_equal(get_layers(map$x$project)$name, "Pin")
  expect_equal(layer_names(map$x$project), "Pin")
})

test_that("describe_project reports only live map controls", {
  summary <- describe_project(geolibre())
  expect_equal(summary$layerCount, 0L)
  expect_length(summary$mapControls, 0L)
  expect_equal(summary$basemapStyleUrl, basemaps()[["liberty"]])
})

test_that("a project file is validated on read", {
  path <- tempfile(fileext = ".json")
  writeLines('{"version":"0.2.0","name":"A","mapView":{},"layers":"nope"}', path)
  expect_error(load_project(path), "layers")
  writeLines("not json at all", path)
  expect_error(load_project(path), "not valid|neither")
  expect_error(load_project(c("a", "b")), "path or JSON string")
})

test_that("a project with no layers list gets one", {
  project <- load_project('{"version":"0.2.0","name":"A","mapView":{}}')
  expect_equal(project$layers, list())
})

test_that("to_html embeds a self-contained page", {
  map <- geolibre() |> add_marker(-77.0369, 38.9072, name = "DC")
  html <- to_html(map, title = "My <Map>")
  expect_match(html, "^<!doctype html>")
  expect_match(html, "My &lt;Map&gt;", fixed = TRUE)
  expect_match(html, "embed=1", fixed = TRUE)
  expect_match(html, "geolibre:load-project", fixed = TRUE)
  # The target origin is pinned rather than broadcast with "*".
  expect_match(html, '"https://web.geolibre.app"', fixed = TRUE)
  expect_no_match(html, 'postMessage(\n      { type: "geolibre:load-project", project: project, seq: 1 },\n      "*"', fixed = TRUE)

  path <- tempfile(fileext = ".html")
  expect_equal(to_html(map, path), path)
  expect_true(file.exists(path))
})

test_that("to_html refuses dimensions that could break out of the style rule", {
  map <- geolibre()
  expect_error(to_html(map, width = "100%; } body { display: none"), "CSS dimension")
  expect_error(to_html(map, height = "1px;}"), "CSS dimension")
  expect_error(to_html(map, app_url = "javascript:alert(1)"), "HTTP")
  expect_silent(to_html(map, width = "calc(100% - 2rem)"))
})

test_that("to_html keeps a property value from escaping the script block", {
  injected <- list(
    type = "Feature",
    properties = list(name = "</script><script>alert(1)</script>"),
    geometry = list(type = "Point", coordinates = c(-77, 39))
  )
  html <- to_html(add_geojson(geolibre(), injected, name = "Injected"))
  expect_no_match(html, "</script><script>alert(1)", fixed = TRUE)
  expect_match(html, "\\u003c", fixed = TRUE)
})
