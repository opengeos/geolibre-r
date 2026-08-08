point_collection <- function(values = c(10, 90)) {
  list(
    type = "FeatureCollection",
    features = lapply(seq_along(values), function(i) {
      list(
        type = "Feature",
        properties = list(pop = values[[i]], label = paste0("f", i)),
        geometry = list(type = "Point", coordinates = c(-77 + i, 38 + i))
      )
    })
  )
}

test_that("style overrides can be passed through dots or the style list", {
  dots <- add_geojson(geolibre(), point_collection(), fillColor = "#ff0000")
  listed <- add_geojson(geolibre(), point_collection(), style = list(fillColor = "#ff0000"))
  expect_equal(dots$x$project$layers[[1]]$style$fillColor, "#ff0000")
  expect_equal(
    listed$x$project$layers[[1]]$style$fillColor,
    dots$x$project$layers[[1]]$style$fillColor
  )
  # Unnamed extras are a mistake, not a silent no-op.
  expect_error(add_geojson(geolibre(), point_collection(), "#ff0000", 1), "named")
})

test_that("every layer carries the application's default style", {
  layer <- add_geojson(geolibre(), point_collection())$x$project$layers[[1]]
  expect_equal(layer$style$strokeWidth, 2)
  expect_equal(layer$style$vectorStyleMode, "single")
  expect_length(layer$style, length(default_layer_style()))
})

test_that("layer ids are unique UUIDs and leave the RNG stream alone", {
  set.seed(42)
  before <- runif(1)
  set.seed(42)
  map <- geolibre() |> add_marker(-77, 39) |> add_marker(-76, 40)
  after <- runif(1)
  expect_equal(before, after)
  ids <- vapply(map$x$project$layers, function(layer) layer$id, character(1))
  expect_length(unique(ids), 2L)
  expect_match(ids, "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")
})

test_that("marker helpers accept pairs, matrices, and data frames", {
  from_pairs <- add_markers(geolibre(), list(c(-77, 39), c(-76, 40)))
  from_matrix <- add_markers(geolibre(), matrix(c(-77, -76, 39, 40), ncol = 2))
  from_frame <- add_markers(geolibre(), data.frame(lng = c(-77, -76), lat = c(39, 40)))
  for (map in list(from_pairs, from_matrix, from_frame)) {
    expect_length(map$x$project$layers[[1]]$geojson$features, 2L)
  }
  expect_equal(
    from_pairs$x$project$layers[[1]]$geojson$features[[1]]$geometry$coordinates,
    c(-77, 39)
  )
  expect_error(add_markers(geolibre(), list(c(-77, 39, 1))), "pair")
  expect_error(add_markers(geolibre(), list(list(lng = -77))), "latitude")
})

test_that("marker layers reject non-point geometries", {
  polygon <- list(
    type = "Polygon",
    coordinates = list(list(c(0, 0), c(1, 0), c(1, 1), c(0, 0)))
  )
  expect_error(add_markers(geolibre(), polygon), "Point")
})

test_that("renderer helpers set the matching style keys", {
  cluster <- add_marker_cluster(geolibre(), list(c(-77, 39)), cluster_radius = 60)
  heat <- add_heatmap(geolibre(), list(c(-77, 39)), radius = 40, intensity = 2)
  circles <- add_circle_markers(geolibre(), list(c(-77, 39)), radius = 12)
  expect_equal(cluster$x$project$layers[[1]]$style$pointRenderer, "cluster")
  expect_equal(cluster$x$project$layers[[1]]$style$clusterRadius, 60L)
  expect_equal(heat$x$project$layers[[1]]$style$pointRenderer, "heatmap")
  expect_equal(heat$x$project$layers[[1]]$style$heatmapIntensity, 2)
  expect_equal(circles$x$project$layers[[1]]$style$circleRadius, 12)
  expect_error(add_heatmap(geolibre(), list(c(-77, 39)), radius = 0), "greater than zero")
  expect_error(add_heatmap(geolibre(), list(c(-77, 39)), intensity = -1), "negative")
})

test_that("tabular sources become point layers", {
  frame <- data.frame(
    name = c("a", "b"),
    longitude = c(-77, -76),
    latitude = c(39, 40),
    stringsAsFactors = FALSE
  )
  from_frame <- add_xy_data(geolibre(), frame)
  from_csv <- add_csv(geolibre(), "name,longitude,latitude\na,-77,39\nb,-76,40")
  expect_length(from_frame$x$project$layers[[1]]$geojson$features, 2L)
  expect_length(from_csv$x$project$layers[[1]]$geojson$features, 2L)
  expect_equal(
    from_csv$x$project$layers[[1]]$geojson$features[[1]]$properties$name,
    "a"
  )
  expect_error(add_xy_data(geolibre(), frame, x = "lon"), "missing coordinate")
  expect_error(
    add_csv(geolibre(), "longitude,latitude\nnot,anumber"),
    "invalid coordinates"
  )
})

test_that("choropleths build graduated stops from the data", {
  map <- add_choropleth(
    geolibre(), point_collection(c(0, 50, 100)), "pop",
    class_count = 3, colormap = "blues"
  )
  style <- map$x$project$layers[[1]]$style
  expect_equal(style$vectorStyleMode, "graduated")
  expect_equal(style$vectorStyleProperty, "pop")
  expect_equal(style$vectorStyleColorRamp, "blues")
  expect_length(style$vectorStyleStops, 3L)
  expect_equal(style$vectorStyleStops[[1]]$value, 0)
  expect_equal(style$vectorStyleStops[[3]]$value, 100)
  expect_error(add_choropleth(geolibre(), point_collection(), "missing"), "not found")
  expect_error(
    add_choropleth(geolibre(), point_collection(), "label"),
    "at least one numeric"
  )
})

test_that("class counts clamp to the range the application supports", {
  wide <- add_choropleth(geolibre(), point_collection(c(1, 2, 3)), "pop", class_count = 50)
  narrow <- add_choropleth(geolibre(), point_collection(c(1, 2, 3)), "pop", class_count = 1)
  expect_length(wide$x$project$layers[[1]]$style$vectorStyleStops, 12L)
  expect_length(narrow$x$project$layers[[1]]$style$vectorStyleStops, 2L)
})

test_that("raster options are validated and recorded", {
  single <- add_cog(
    geolibre(), "https://example.com/a.tif",
    bands = 1, colormap = "terrain", rescale = c(0, 100)
  )
  state <- single$x$project$layers[[1]]$metadata$rasterState
  expect_equal(state$mode, "single")
  expect_equal(state$colormap, "terrain")
  expect_equal(state$rescale, list(c(0, 100)))
  expect_equal(
    single$x$project$layers[[1]]$metadata$nativeLayerIds,
    list(single$x$project$layers[[1]]$id)
  )
})

test_that("service layers build the URLs the application expects", {
  wms <- add_wms(
    geolibre(), "https://example.com/wms",
    layers = "topp:states", version = "1.3.0"
  )
  source <- wms$x$project$layers[[1]]$source
  expect_match(source$tiles[[1]], "SERVICE=WMS")
  expect_match(source$tiles[[1]], "CRS=EPSG%3A3857")
  # The bounding-box placeholder must survive unencoded for per-tile substitution.
  expect_match(source$tiles[[1]], "BBOX={bbox-epsg-3857}", fixed = TRUE)
  expect_equal(source$version, "1.3.0")

  legacy <- add_wms(geolibre(), "https://example.com/wms", layers = "a")
  expect_match(legacy$x$project$layers[[1]]$source$tiles[[1]], "SRS=EPSG%3A3857")

  url <- wfs_getfeature_url(
    "https://example.com/wfs", "topp:states",
    version = "2.0.0", max_features = 10
  )
  expect_match(url, "typeNames=topp%3Astates")
  expect_match(url, "count=10")
  expect_match(
    wfs_getfeature_url("https://example.com/wfs", "a", version = "1.1.0", max_features = 5),
    "maxFeatures=5"
  )
})

test_that("tile, pmtiles, 3D tiles, and video layers take their documented shape", {
  map <- geolibre() |>
    add_tile_layer("https://tile.example.com/{z}/{x}/{y}.png", attribution = "Example") |>
    add_pmtiles("https://example.com/a.pmtiles", tile_type = "raster") |>
    add_3d_tiles("https://example.com/tileset.json", altitude_offset = 5) |>
    add_video(
      "https://example.com/c.mp4",
      list(c(-77.1, 39), c(-77, 39), c(-77, 38.9), c(-77.1, 38.9))
    )
  layers <- map$x$project$layers
  expect_equal(layers[[1]]$source$attribution, "Example")
  expect_equal(layers[[1]]$source$tiles, list("https://tile.example.com/{z}/{x}/{y}.png"))
  expect_equal(layers[[2]]$metadata$nativeLayerIds, list(paste0(layers[[2]]$id, "-raster")))
  expect_equal(layers[[3]]$metadata$altitudeOffset, 5)
  expect_equal(layers[[4]]$metadata$bounds, c(-77.1, 38.9, -77, 39))
  expect_error(
    add_video(geolibre(), "http://example.com/c.mp4", list(c(0, 0), c(1, 0), c(1, 1), c(0, 1))),
    "https://"
  )
  expect_error(add_video(geolibre(), "https://example.com/c.mp4", list(c(0, 0))), "four")
})

test_that("remote vector sources are handed to the browser rather than inlined", {
  map <- add_geoparquet(geolibre(), "https://example.com/a.parquet")
  layer <- map$x$project$layers[[1]]
  expect_null(layer$geojson)
  expect_equal(layer$metadata$sourceKind, "maplibre-gl-vector")
  expect_equal(layer$metadata$vectorState$format, "parquet")
  expect_equal(layer$metadata$sourceIds, list(paste0(layer$id, "-source")))
  expect_equal(
    add_flatgeobuf(geolibre(), "https://e.com/a.fgb")$x$project$layers[[1]]$metadata$vectorState$format,
    "flatgeobuf"
  )
  expect_equal(
    add_gpkg(geolibre(), "https://e.com/a.gpkg", layer = "parcels")$x$project$layers[[1]]$metadata$vectorState$sourceLayer,
    "parcels"
  )
})

test_that("a source URL is recorded when GeoJSON came from one", {
  layer <- add_geojson(geolibre(), point_collection())$x$project$layers[[1]]
  expect_null(layer$sourcePath)
  expect_null(layer$source$url)
})

test_that("the basemap pseudo-id cannot name a layer", {
  expect_error(add_marker(geolibre(), -77, 39, name = "__basemap__"), "reserved")
  expect_error(
    rename_layer(add_marker(geolibre(), -77, 39, name = "Pin"), "Pin", "__basemap__"),
    "reserved"
  )
})

test_that("sf objects are reprojected and stripped of writer artifacts", {
  skip_if_not_installed("sf")
  point <- sf::st_sf(
    label = "DC",
    geometry = sf::st_sfc(sf::st_point(c(-77.0369, 38.9072)), crs = 4326)
  )
  collection <- add_sf(geolibre(), point, "Place")$x$project$layers[[1]]$geojson
  expect_equal(collection$type, "FeatureCollection")
  expect_equal(collection$features[[1]]$properties$label, "DC")
  # The writer's temporary filename must not leak into the saved project.
  expect_null(collection$name)
  expect_null(collection$crs)

  utm <- sf::st_transform(point, 32618)
  reprojected <- add_sf(geolibre(), utm, "UTM")$x$project$layers[[1]]$geojson
  expect_equal(
    unlist(reprojected$features[[1]]$geometry$coordinates),
    c(-77.0369, 38.9072),
    tolerance = 1e-6
  )

  # A bare geometry with no CRS is taken as longitude/latitude.
  expect_length(add_sf(geolibre(), sf::st_point(c(1, 2)))$x$project$layers, 1L)
  expect_error(add_sf(geolibre(), list(type = "Point")), "sf, sfc, or sfg")
})

test_that("add_sf names the layer after the expression it was given", {
  skip_if_not_installed("sf")
  places <- sf::st_sf(geometry = sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326))
  expect_equal(layer_names(add_sf(geolibre(), places)), "places")
})
