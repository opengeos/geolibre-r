test_that("camera setters change only what they name", {
  map <- geolibre() |>
    set_center(-77, 39, zoom = 11) |>
    set_bearing(45) |>
    set_pitch(60)
  view <- map$x$project$mapView
  expect_equal(view$center, c(-77, 39))
  expect_equal(view$zoom, 11)
  expect_equal(view$bearing, 45)
  expect_equal(view$pitch, 60)
  expect_equal(set_zoom(map, 3)$x$project$mapView$bearing, 45)
})

test_that("zoom and pitch clamp to the ranges the application supports", {
  expect_equal(set_zoom(geolibre(), 99)$x$project$mapView$zoom, 24)
  expect_equal(set_zoom(geolibre(), -5)$x$project$mapView$zoom, 0)
  expect_equal(set_pitch(geolibre(), 120)$x$project$mapView$pitch, 85)
  expect_equal(set_pitch(geolibre(), -10)$x$project$mapView$pitch, 0)
})

test_that("fit_bounds resolves a box to a camera and records the box", {
  map <- fit_bounds(geolibre(), c(-125, 24, -66, 50))
  view <- map$x$project$mapView
  expect_equal(view$bbox, c(-125, 24, -66, 50))
  expect_equal(view$center[[1]], -95.5)
  expect_true(view$center[[2]] > 24 && view$center[[2]] < 50)
  expect_true(view$zoom > 2 && view$zoom < 6)
})

test_that("fit_bounds frames a box crossing the antimeridian", {
  view <- fit_bounds(geolibre(), c(170, -20, -170, -10))$x$project$mapView
  # A 20-degree span centered on the meridian, not a 340-degree span.
  expect_equal(view$center[[1]], 180)
  expect_true(view$zoom > 4)
})

test_that("fit_bounds rejects boxes outside Web Mercator", {
  expect_error(fit_bounds(geolibre(), c(-10, 50, 10, 20)), "inverted")
  expect_error(fit_bounds(geolibre(), c(-10, -90, 10, 10)), "Web Mercator")
  expect_error(fit_bounds(geolibre(), c(-10, 0, 10, 10), padding = -1), "negative")
})

test_that("a degenerate box falls back to a close-in zoom", {
  expect_equal(fit_bounds(geolibre(), c(-77, 39, -77, 39))$x$project$mapView$zoom, 14)
})

test_that("set_view delegates a bbox to fit_bounds and keeps bearing and pitch", {
  view <- set_view(geolibre(), bbox = c(-125, 24, -66, 50), bearing = 15, pitch = 30)$x$project$mapView
  expect_equal(view$bbox, c(-125, 24, -66, 50))
  expect_equal(view$bearing, 15)
  expect_equal(view$pitch, 30)
})

test_that("moving the camera by hand drops a stale fitted bbox", {
  fitted <- fit_bounds(geolibre(), c(-125, 24, -66, 50))
  expect_null(set_center(fitted, -77, 39)$x$project$mapView$bbox)
  expect_null(set_zoom(fitted, 8)$x$project$mapView$bbox)
  # Rotating and tilting do not change the extent, so the box still describes it.
  expect_equal(set_bearing(fitted, 20)$x$project$mapView$bbox, c(-125, 24, -66, 50))
})

test_that("basemaps resolve by name or URL", {
  expect_equal(
    set_basemap(geolibre(), "dark")$x$project$basemapStyleUrl,
    "https://tiles.openfreemap.org/styles/dark"
  )
  expect_equal(
    add_basemap(geolibre(), "https://example.com/style.json")$x$project$basemapStyleUrl,
    "https://example.com/style.json"
  )
  expect_equal(geolibre(basemap = "positron")$x$project$basemapStyleUrl, basemaps()[["positron"]])
  expect_error(set_basemap(geolibre(), "nope"), "Unknown basemap")
  expect_named(basemaps())
})

test_that("the project name can be set", {
  expect_equal(set_project_name(geolibre(), "  Bay  ")$x$project$name, "Bay")
  expect_error(set_project_name(geolibre(), "   "), "non-empty")
})

test_that("legends accept each of the three entry sources", {
  from_named <- add_legend(geolibre(), "LC", legend = c(Water = "#466b9f"))
  from_pairs <- add_legend(geolibre(), "LC", labels = "Water", colors = "#466b9f")
  from_preset <- add_legend(geolibre(), builtin = "nlcd")
  entry <- from_named$x$project$plugins$settings[["maplibre-gl-components"]]$legend
  expect_equal(entry$title, "LC")
  expect_equal(entry$items[[1]]$label, "Water")
  expect_equal(entry$items[[1]]$shape, "square")
  expect_equal(entry$legendPosition, "bottom-left")
  expect_equal(
    from_pairs$x$project$plugins$settings[["maplibre-gl-components"]]$legend$items,
    entry$items
  )
  preset <- from_preset$x$project$plugins$settings[["maplibre-gl-components"]]$legend
  expect_equal(preset$title, "NLCD Land Cover")
  expect_length(preset$items, 20L)
})

test_that("legends accumulate and validate their arguments", {
  map <- geolibre() |>
    add_legend(legend = c(A = "#000")) |>
    add_legend(legend = c(B = "#fff"), position = "top-right")
  legend <- map$x$project$plugins$settings[["maplibre-gl-components"]]$legend
  expect_length(legend$legends, 2L)
  expect_equal(legend$selectedLegendIndex, 1L)
  expect_error(add_legend(geolibre()), "Provide legend entries")
  expect_error(add_legend(geolibre(), legend = c(A = "#000"), builtin = "nlcd"), "exactly one")
  expect_error(add_legend(geolibre(), labels = c("a", "b"), colors = "#000"), "same length")
  expect_error(add_legend(geolibre(), labels = "a"), "together")
  expect_error(add_legend(geolibre(), legend = "#000"), "named")
  expect_error(add_legend(geolibre(), builtin = "nope"), "Unknown built-in legend")
})

test_that("colorbars support named ramps and custom gradients", {
  named <- add_colorbar(geolibre(), colormap = "terrain", vmin = 0, vmax = 3000, units = "m")
  custom <- add_colorbar(geolibre(), colors = c("#000", "#fff"), vmax = 10)
  named_entry <- named$x$project$plugins$settings[["maplibre-gl-components"]]$colorbar
  custom_entry <- custom$x$project$plugins$settings[["maplibre-gl-components"]]$colorbar
  expect_equal(named_entry$mode, "named")
  expect_equal(named_entry$customColors, "")
  expect_equal(named_entry$units, "m")
  expect_equal(custom_entry$mode, "custom")
  expect_equal(custom_entry$customColors, "#000, #fff")
  expect_error(add_colorbar(geolibre(), vmin = 1, vmax = 1), "must be less than")
  expect_error(add_colorbar(geolibre(), colors = character(0)), "non-empty")
  expect_error(add_colorbar(geolibre(), position = "middle"), "should be one of")
  expect_equal(
    add_colormap(geolibre(), "plasma", vmax = 5)$x$project$plugins$settings[["maplibre-gl-components"]]$colorbar$colormap,
    "plasma"
  )
})

test_that("a legend and a colorbar coexist in one settings blob", {
  components <- geolibre() |>
    add_legend(legend = c(A = "#000")) |>
    add_colorbar(vmax = 2)
  blob <- components$x$project$plugins$settings[["maplibre-gl-components"]]
  expect_true(all(c("legend", "colorbar") %in% names(blob)))
  expect_equal(describe_project(components)$mapControls, c("legend", "colorbar"))
})

test_that("split_map resolves layer references and seeds the default plugins", {
  map <- geolibre() |>
    add_marker(-77, 39, name = "Before") |>
    add_marker(-76, 40, name = "After") |>
    split_map("Before", c("After", "__basemap__"), position = 120)
  plugins <- map$x$project$plugins
  swipe <- plugins$settings[["maplibre-gl-swipe"]]
  expect_equal(swipe$leftLayers, list(map$x$project$layers[[1]]$id))
  expect_equal(swipe$rightLayers[[2]], "__basemap__")
  # A clamped position, not a rejected one.
  expect_equal(swipe$position, 100)
  expect_true("maplibre-gl-swipe" %in% unlist(plugins$activePluginIds))
  expect_true("maplibre-layer-control" %in% unlist(plugins$activePluginIds))
  expect_equal(plugins$mapControlPositions[["maplibre-gl-swipe"]], "top-left")
  expect_error(split_map(map, "Missing", "After"), "No layer matches")
})

test_that("the components plugin is configured without being activated", {
  # Activating it would also mount the full Components toolbar.
  plugins <- add_legend(geolibre(), legend = c(A = "#000"))$x$project$plugins
  expect_false("maplibre-gl-components" %in% unlist(plugins$activePluginIds))
  expect_true("maplibre-gl-components" %in% names(plugins$settings))
})
