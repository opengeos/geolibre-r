test_that("the color ramp catalog matches the application's", {
  expect_true(all(c("viridis", "terrain", "rdylbu", "greys") %in% color_ramp_names()))
  expect_equal(get_color_ramp("viridis")[[1]], "#440154")
  # An unknown ramp falls back to the default, as the application's lookup does.
  expect_equal(get_color_ramp("nope"), get_color_ramp("viridis"))
})

test_that("ramp interpolation reproduces the anchors at the ends", {
  colors <- interpolate_ramp_colors("viridis", 4)
  expect_equal(colors, get_color_ramp("viridis"))
  expect_length(interpolate_ramp_colors("blues", 7), 7L)
  expect_equal(interpolate_ramp_colors("blues", 1), "#1e3a8a")
  # A midpoint of a two-stop ramp is the blend of its ends.
  expect_equal(interpolate_ramp_colors("gray", 3)[[2]], "#808080")
})

test_that("classification schemes produce the breaks they promise", {
  values <- as.list(c(0, 1, 2, 3, 100))
  equal <- graduated_stops(values, class_count = 5, classification_scheme = "equal-interval")
  quantile <- graduated_stops(values, class_count = 5, classification_scheme = "quantile")
  expect_equal(vapply(equal, function(s) s$value, numeric(1)), c(0, 25, 50, 75, 100))
  expect_equal(vapply(quantile, function(s) s$value, numeric(1)), c(0, 1, 2, 3, 100))
  expect_error(graduated_stops(values, classification_scheme = "natural"), "scheme")
})

test_that("non-numeric and non-finite values are dropped from a classification", {
  stops <- graduated_stops(list(1, "abc", NA, NULL, 9), class_count = 2)
  expect_equal(vapply(stops, function(s) s$value, numeric(1)), c(1, 9))
  # A single distinct value has no range to classify.
  expect_length(graduated_stops(list(5, 5, 5)), 1L)
})

test_that("the built-in legend presets are complete and aliased", {
  expect_equal(builtin_legend_names(), c("esa_worldcover", "nlcd"))
  for (name in c("esa", "worldcover", "esa_world_cover", "ESA_WorldCover")) {
    expect_equal(get_builtin_legend(name)$title, "ESA WorldCover")
  }
  for (preset in builtin_legend_names()) {
    entry <- get_builtin_legend(preset)
    expect_length(entry$labels, length(entry$colors))
    expect_match(entry$colors, "^#[0-9a-f]{6}$")
  }
})

test_that("query strings are built the way the application builds them", {
  expect_equal(
    append_query("https://e.com/wms", list(A = "1", B = "x y")),
    "https://e.com/wms?A=1&B=x%20y"
  )
  expect_equal(
    append_query("https://e.com/wms?existing=1", list(A = "2")),
    "https://e.com/wms?existing=1&A=2"
  )
  expect_equal(append_query("https://e.com/wms?", list(A = "2")), "https://e.com/wms?A=2")
  # The bounding-box placeholder must reach the server unencoded.
  expect_equal(
    append_query("https://e.com/wms", list(BBOX = "{bbox-epsg-3857}")),
    "https://e.com/wms?BBOX={bbox-epsg-3857}"
  )
  # A query string has to precede any fragment.
  expect_equal(append_query("https://e.com/wms#frag", list(A = "1")), "https://e.com/wms?A=1#frag")
})
