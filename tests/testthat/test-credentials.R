test_that("credential query parameters are stripped and the rest is left intact", {
  expect_equal(
    redact_url("https://t.example.com/s.json?api_key=secret&lang=en"),
    "https://t.example.com/s.json?lang=en"
  )
  expect_equal(
    redact_url("https://t.example.com/s.json?API-KEY=secret"),
    "https://t.example.com/s.json"
  )
  expect_equal(
    redact_url("https://t.example.com/a.tif?x-amz-signature=abc&band=1"),
    "https://t.example.com/a.tif?band=1"
  )
  expect_equal(
    redact_url("https://blob.example.com/a.tif?sv=2021&sig=abc&keep=1"),
    "https://blob.example.com/a.tif?keep=1"
  )
  expect_equal(redact_url("https://user:pw@example.com/a.tif"), "https://example.com/a.tif")
  # A URL with nothing to strip comes back byte-for-byte.
  expect_equal(
    redact_url("https://tile.example.com/{z}/{x}/{y}.png?style=dark"),
    "https://tile.example.com/{z}/{x}/{y}.png?style=dark"
  )
  expect_equal(redact_url("plain-string"), "plain-string")
})

test_that("layer request headers are removed unless explicitly kept", {
  map <- add_3d_tiles(
    geolibre(), "https://example.com/tileset.json",
    request_headers = list(Authorization = "Bearer secret")
  )
  expect_equal(
    get_project(map, keep_credentials = TRUE)$layers[[1]]$source$requestHeaders$Authorization,
    "Bearer secret"
  )
  expect_null(get_project(map)$layers[[1]]$source$requestHeaders)
  expect_null(redact_layer(map$x$project$layers[[1]])$source$requestHeaders)
  # The rest of the source survives.
  expect_equal(get_project(map)$layers[[1]]$source$url, "https://example.com/tileset.json")
})

test_that("a signed source URL is swept everywhere it appears on a layer", {
  map <- add_raster(geolibre(), "https://example.com/a.tif?access_token=abc", name = "Image")
  safe <- get_project(map)$layers[[1]]
  expect_equal(safe$source$url, "https://example.com/a.tif")
  expect_equal(safe$sourcePath, "https://example.com/a.tif")
})

test_that("basemap, geocoding, and environment secrets are cleared", {
  project <- geolibre(basemap = "https://tiles.example.com/style.json?key=secret")$x$project
  project$preferences$environmentVariables <- list(list(name = "TOKEN", value = "abc"))
  project$preferences$geocoding <- list(
    apiKeys = list(nominatim = "secret"),
    forwardEndpoint = "https://geo.example.com/search?api_key=secret"
  )
  safe <- redact_credentials(project)
  expect_equal(safe$basemapStyleUrl, "https://tiles.example.com/style.json")
  expect_equal(safe$preferences$environmentVariables, list())
  expect_equal(safe$preferences$geocoding$apiKeys, structure(list(), names = character(0)))
  expect_equal(safe$preferences$geocoding$forwardEndpoint, "https://geo.example.com/search")
})

test_that("first-party map controls survive redaction but other plugins do not", {
  map <- geolibre() |>
    add_marker(-77, 39, name = "Pin") |>
    add_legend(legend = c(Pin = "#3b82f6")) |>
    split_map("Pin", "__basemap__")
  project <- map$x$project
  project$plugins$settings[["third-party-plugin"]] <- list(apiKey = "secret")
  safe <- redact_credentials(project)
  expect_true("maplibre-gl-swipe" %in% names(safe$plugins$settings))
  expect_true("legend" %in% names(safe$plugins$settings[["maplibre-gl-components"]]))
  expect_false("third-party-plugin" %in% names(safe$plugins$settings))
})

test_that("a hand-authored HTML panel is dropped with the unknown blobs", {
  project <- add_legend(geolibre(), legend = c(A = "#000"))$x$project
  project$plugins$settings[["maplibre-gl-components"]]$html <- "<a href='https://x/?token=abc'>"
  safe <- redact_credentials(project)
  components <- safe$plugins$settings[["maplibre-gl-components"]]
  expect_null(components$html)
  expect_false(is.null(components$legend))
})

test_that("inlined GeoJSON is left alone by the credential sweep", {
  collection <- list(
    type = "FeatureCollection",
    features = list(list(
      type = "Feature",
      properties = list(token = "not-a-secret", link = "https://example.com/?api_key=keep"),
      geometry = list(type = "Point", coordinates = c(-77, 39))
    ))
  )
  safe <- get_project(add_geojson(geolibre(), collection, name = "Places"))
  properties <- safe$layers[[1]]$geojson$features[[1]]$properties
  expect_equal(properties$token, "not-a-secret")
  expect_equal(properties$link, "https://example.com/?api_key=keep")
})

test_that("save_project strips credentials by default", {
  map <- add_3d_tiles(
    geolibre(), "https://example.com/tileset.json",
    request_headers = list(Authorization = "Bearer secret")
  )
  path <- tempfile(fileext = ".geolibre.json")
  save_project(map, path)
  expect_no_match(paste(readLines(path), collapse = ""), "Bearer secret", fixed = TRUE)
  save_project(map, path, keep_credentials = TRUE)
  expect_match(paste(readLines(path), collapse = ""), "Bearer secret", fixed = TRUE)
  expect_error(save_project(map, path, keep_credentials = NA), "keep_credentials")
})

test_that("the credential sweep terminates on a deeply nested structure", {
  project <- geolibre()$x$project
  nested <- list(value = "leaf")
  for (i in 1:30) nested <- list(child = nested)
  project$metadata <- nested
  expect_silent(redact_credentials(project))
})
