recording_session <- function() {
  sent <- new.env(parent = emptyenv())
  sent$messages <- list()
  list(
    ns = function(id) paste0("ns-", id),
    sendCustomMessage = function(type, message) {
      sent$messages[[length(sent$messages) + 1L]] <- list(type = type, message = message)
      invisible(NULL)
    },
    sent = sent
  )
}

last_message <- function(session) {
  session$sent$messages[[length(session$sent$messages)]]
}

test_that("proxy commands are addressed to the namespaced widget", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)
  expect_invisible(geolibre_command(proxy, "toImage"))
  sent <- last_message(session)
  expect_equal(sent$type, "geolibre:command")
  expect_equal(sent$message$id, "ns-map")
  expect_equal(sent$message$method, "toImage")
  expect_match(sent$message$requestId, "^[0-9a-f]{8}-")
  # An empty parameter set must serialize as an object, not an array.
  expect_equal(sent$message$params, structure(list(), names = character(0)))
})

test_that("a caller-supplied request id is passed through for correlation", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)
  geolibre_get_view(proxy, request_id = "req-1")
  expect_equal(last_message(session)$message$requestId, "req-1")
})

test_that("camera commands carry the parameter names the bridge expects", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)

  geolibre_fly_to(proxy, center = c(-77, 39), zoom = 12, duration = 1500)
  params <- last_message(session)$message$params
  expect_equal(params$center, c(-77, 39))
  expect_equal(params$zoom, 12)
  expect_equal(params$duration, 1500)
  expect_null(params$pitch)

  geolibre_fit_bounds(proxy, c(-125, 24, -66, 50))
  expect_equal(last_message(session)$message$params$bounds, c(-125, 24, -66, 50))

  geolibre_identify(proxy, c(-77, 39), layer_id = "abc")
  identify_params <- last_message(session)$message$params
  expect_equal(identify_params$lngLat, c(-77, 39))
  expect_equal(identify_params$layerId, "abc")

  geolibre_zoom_to_layer(proxy, "abc")
  expect_equal(last_message(session)$message$method, "zoomToLayer")
  expect_equal(last_message(session)$message$params$layerId, "abc")
})

test_that("feature and processing commands map to their bridge methods", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)
  expectations <- list(
    list(call = function() geolibre_layer_features(proxy, "abc"), method = "getLayerFeatures"),
    list(call = function() geolibre_selected_features(proxy), method = "getSelectedFeatures"),
    list(call = function() geolibre_drawn_features(proxy), method = "getDrawnFeatures"),
    list(call = function() geolibre_list_algorithms(proxy), method = "listAlgorithms"),
    list(call = function() geolibre_to_image(proxy), method = "toImage")
  )
  for (expectation in expectations) {
    expectation$call()
    expect_equal(last_message(session)$message$method, expectation$method)
  }
  geolibre_run_algorithm(proxy, "buffer", list(layerId = "abc", distance = 500))
  params <- last_message(session)$message$params
  expect_equal(last_message(session)$message$method, "runAlgorithm")
  expect_equal(params$id, "buffer")
  expect_equal(params$params$distance, 500)
})

test_that("proxy commands validate their arguments", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)
  expect_error(geolibre_fly_to(proxy), "at least one")
  expect_error(geolibre_fly_to(proxy, center = 1), "longitude")
  expect_error(geolibre_fit_bounds(proxy, c(0, 0, 1)), "four finite")
  expect_error(geolibre_command(proxy, "flyTo", list(1)), "named list")
  expect_error(geolibre_command(proxy, ""), "non-empty")
  expect_error(geolibre_command("not a proxy", "toImage"), "geolibre_proxy")
  expect_error(update_geolibre("not a proxy", geolibre()), "geolibre_proxy")
})

test_that("update_geolibre accepts a widget or a bare project", {
  skip_if_not_installed("shiny")
  session <- recording_session()
  proxy <- geolibre_proxy("map", session = session)
  update_geolibre(proxy, geolibre(name = "From widget"))
  expect_equal(last_message(session)$type, "geolibre:update")
  expect_equal(last_message(session)$message$project$name, "From widget")
  update_geolibre(proxy, geolibre(name = "From project")$x$project)
  expect_equal(last_message(session)$message$project$name, "From project")
})
