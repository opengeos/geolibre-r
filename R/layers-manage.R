# Inspecting and rearranging the layers already on a map.
#
# Every function taking a `layer` argument accepts either a layer id or a layer
# name. An exact id match wins outright; a name shared by several layers is an
# error rather than an arbitrary pick, so reference such a layer by id.

#' Remove a layer
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   remove_layer("Pin")
#' stopifnot(length(map$x$project$layers) == 0L)
#' @export
remove_layer <- function(map, layer) {
  update_project(map, function(project) {
    position <- find_layer_position(project, layer)
    layer_id <- project$layers[[position]]$id
    project$layers <- project$layers[-position]
    # A swipe control must not keep pointing at a layer that is gone.
    drop_swipe_reference(project, layer_id)
  })
}

#' Remove every layer
#'
#' @param map A GeoLibre widget.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39) |> clear_layers()
#' stopifnot(length(map$x$project$layers) == 0L)
#' @export
clear_layers <- function(map) {
  update_project(map, function(project) {
    project$layers <- empty_array()
    project
  })
}

drop_swipe_reference <- function(project, layer_id) {
  swipe <- project$plugins$settings[[SWIPE_PLUGIN_ID]]
  if (!is.list(swipe)) return(project)
  for (side in c("leftLayers", "rightLayers")) {
    ids <- unlist(swipe[[side]], use.names = FALSE)
    if (length(ids)) swipe[[side]] <- as_json_array(ids[ids != layer_id])
  }
  project$plugins$settings[[SWIPE_PLUGIN_ID]] <- swipe
  project
}

#' Layer names in draw order
#'
#' @param x A GeoLibre widget or a project list.
#' @return A character vector of layer names, bottom layer first.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39, name = "Pin")
#' layer_names(map)
#' @export
layer_names <- function(x) {
  layers <- project_layers(as_project_list(x))
  vapply(
    layers,
    function(layer) if (is_scalar_string(layer$name)) layer$name else NA_character_,
    character(1)
  )
}

#' Summarize a project's layers
#'
#' @param x A GeoLibre widget or a project list.
#' @return A data frame with one row per layer, in draw order, holding its `id`,
#'   `name`, `type`, `visible`, `opacity`, `source` URL (credentials stripped),
#'   and inlined `features` count.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   add_raster("https://example.com/image.tif", name = "Image")
#' get_layers(map)
#' @export
get_layers <- function(x) {
  layers <- project_layers(as_project_list(x))
  if (!length(layers)) {
    return(data.frame(
      id = character(0), name = character(0), type = character(0),
      visible = logical(0), opacity = numeric(0), source = character(0),
      features = integer(0), stringsAsFactors = FALSE
    ))
  }
  summaries <- lapply(layers, layer_summary)
  data.frame(
    id = vapply(summaries, function(s) s$id, character(1)),
    name = vapply(summaries, function(s) s$name, character(1)),
    type = vapply(summaries, function(s) s$type, character(1)),
    visible = vapply(summaries, function(s) s$visible, logical(1)),
    opacity = vapply(summaries, function(s) s$opacity, numeric(1)),
    source = vapply(summaries, function(s) s$source, character(1)),
    features = vapply(summaries, function(s) s$features, integer(1)),
    stringsAsFactors = FALSE
  )
}

# One layer's identity, visibility, and source, with any inlined data reduced to
# a feature count and the source URL swept of credentials.
layer_summary <- function(layer) {
  source <- layer$source
  url <- if (is.list(source)) {
    candidate <- source$url
    if (is.null(candidate)) candidate <- unlist(source$tiles, use.names = FALSE)[1]
    candidate
  } else {
    NULL
  }
  features <- if (is.list(layer$geojson) && is.list(layer$geojson$features)) {
    length(layer$geojson$features)
  } else {
    NA_integer_
  }
  list(
    id = if (is_scalar_string(layer$id)) layer$id else NA_character_,
    name = if (is_scalar_string(layer$name)) layer$name else NA_character_,
    type = if (is_scalar_string(layer$type)) layer$type else NA_character_,
    visible = isTRUE(layer$visible),
    opacity = if (is_scalar_number(layer$opacity)) as.numeric(layer$opacity) else NA_real_,
    source = if (is_scalar_string(url)) redact_url(url) else NA_character_,
    features = as.integer(features)
  )
}

#' Read one layer's full definition
#'
#' @param x A GeoLibre widget or a project list.
#' @param layer A layer id or layer name.
#' @return The layer as a list, with credential-bearing fields stripped.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39, name = "Pin")
#' get_layer(map, "Pin")$type
#' @export
get_layer <- function(x, layer) {
  project <- as_project_list(x)
  redact_layer(project$layers[[find_layer_position(project, layer)]])
}

#' Position of a layer in the draw order
#'
#' @param x A GeoLibre widget or a project list.
#' @param name A layer id or layer name.
#' @return The one-based index of the first matching layer, or `-1` when none
#'   matches. Unlike the functions that modify a layer, a name several layers
#'   share resolves to the first of them rather than raising.
#' @examples
#' map <- geolibre() |> add_marker(-77, 39, name = "Pin")
#' find_layer_index(map, "Pin")
#' find_layer_index(map, "Missing")
#' @export
find_layer_index <- function(x, name) {
  if (!is_scalar_string(name)) {
    stop_geolibre("`name` must be a single layer id or layer name.")
  }
  layers <- project_layers(as_project_list(x))
  if (!length(layers)) return(-1L)
  field <- function(key) {
    vapply(
      layers,
      function(layer) if (is_scalar_string(layer[[key]])) layer[[key]] else NA_character_,
      character(1)
    )
  }
  ids <- field("id")
  names_vector <- field("name")
  for (matches in list(which(ids == name),
                       which(names_vector == name),
                       which(tolower(names_vector) == tolower(name)))) {
    if (length(matches)) return(matches[[1]])
  }
  -1L
}

#' Show or hide a layer
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param visible `TRUE` to show the layer, `FALSE` to hide it.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   set_layer_visibility("Pin", FALSE)
#' stopifnot(isFALSE(map$x$project$layers[[1]]$visible))
#' @export
set_layer_visibility <- function(map, layer, visible = TRUE) {
  check_flag(visible, "visible")
  mutate_layer(map, layer, function(target) {
    target$visible <- visible
    target
  })
}

#' @rdname set_layer_visibility
#' @export
show_layer <- function(map, layer) {
  set_layer_visibility(map, layer, TRUE)
}

#' @rdname set_layer_visibility
#' @export
hide_layer <- function(map, layer) {
  set_layer_visibility(map, layer, FALSE)
}

#' Set a layer's opacity
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param opacity Opacity from zero to one.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   set_layer_opacity("Pin", 0.4)
#' stopifnot(map$x$project$layers[[1]]$opacity == 0.4)
#' @export
set_layer_opacity <- function(map, layer, opacity) {
  opacity <- validate_opacity(opacity)
  mutate_layer(map, layer, function(target) {
    target$opacity <- opacity
    target
  })
}

#' Rename a layer
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param name The new display name. Surrounding whitespace is stripped.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   rename_layer("Pin", "Capital")
#' stopifnot(layer_names(map) == "Capital")
#' @export
rename_layer <- function(map, layer, name) {
  name <- trimws(check_string(name, "name"))
  if (!nzchar(name)) stop_geolibre("`name` must be a single non-empty string.")
  reject_reserved_name(name)
  mutate_layer(map, layer, function(target) {
    target$name <- name
    target
  })
}

#' Move a layer in the draw order
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param index One-based destination position, counted from the bottom of the
#'   draw order. Negative values count from the top, so `-1` moves the layer to
#'   the very top. Out-of-range values are clamped.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Bottom") |>
#'   add_marker(-76, 40, name = "Top") |>
#'   move_layer("Top", 1)
#' stopifnot(layer_names(map)[[1]] == "Top")
#' @export
move_layer <- function(map, layer, index) {
  index <- check_number(index, "index")
  if (index != floor(index) || index == 0) {
    stop_geolibre("`index` must be a non-zero integer position.")
  }
  update_project(map, function(project) {
    position <- find_layer_position(project, layer)
    target <- project$layers[[position]]
    remaining <- project$layers[-position]
    total <- length(remaining) + 1L
    destination <- if (index < 0) total + index + 1L else index
    destination <- as.integer(clamp(destination, 1L, total))
    project$layers <- append(remaining, list(target), after = destination - 1L)
    project
  })
}

#' Duplicate a layer
#'
#' The copy is appended to the top of the draw order, where a newly added layer
#' lands. Use [move_layer()] to put it elsewhere.
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param name Name for the copy. Defaults to the source name followed by
#'   `" copy"`.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   duplicate_layer("Pin")
#' stopifnot(layer_names(map)[[2]] == "Pin copy")
#' @export
duplicate_layer <- function(map, layer, name = NULL) {
  if (!is.null(name)) {
    name <- trimws(check_string(name, "name"))
    if (!nzchar(name)) stop_geolibre("`name` must be a single non-empty string.")
    reject_reserved_name(name)
  }
  update_project(map, function(project) {
    source <- project$layers[[find_layer_position(project, layer)]]
    old_id <- source$id
    source$id <- new_uuid()
    source$name <- if (is.null(name)) {
      paste(if (is_scalar_string(source$name)) source$name else "Layer", "copy")
    } else {
      name
    }
    # Layer kinds that key their source and native layer ids off their own layer
    # id must be re-keyed, or the copy would collide with its source in the
    # application's layer sync.
    source <- rekey_layer_sources(source, old_id)
    project$layers <- c(project$layers, list(source))
    project
  })
}

# Re-point the id-derived fields a duplicated layer carries at its new id.
#
# The ids are built by suffixing the layer id ("<id>-raster", "<id>-source", or
# a per-source-layer name), so substituting the prefix preserves each suffix and
# keeps a layer that carries several of them distinct. A UUID holds no regular
# expression metacharacters, so it is safe to anchor on directly.
rekey_layer_sources <- function(layer, old_id) {
  id <- layer$id
  if (!is_scalar_string(old_id)) return(layer)
  if (is.list(layer$source) && !is.null(layer$source$sourceId)) {
    layer$source$sourceId <- id
  }
  if (!is.list(layer$metadata)) return(layer)
  if (!is.null(layer$metadata$sourceId)) layer$metadata$sourceId <- id
  for (field in c("nativeLayerIds", "sourceIds")) {
    # Absent stays absent, and an empty array stays an empty array: a vector
    # layer ships `nativeLayerIds: []` on purpose, and assigning NULL would drop
    # the field rather than keep it empty.
    if (is.null(layer$metadata[[field]])) next
    values <- unlist(layer$metadata[[field]], use.names = FALSE)
    layer$metadata[[field]] <- if (length(values)) {
      as_json_array(sub(paste0("^", old_id), id, values))
    } else {
      empty_array()
    }
  }
  layer
}

#' Restyle a layer
#'
#' Merges style overrides into a layer's existing style. Keys not mentioned keep
#' their current values.
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name.
#' @param style Named list of style keys to set.
#' @param ... Additional style overrides given as named arguments.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_marker(-77, 39, name = "Pin") |>
#'   set_layer_style("Pin", fillColor = "#f59e0b", circleRadius = 9)
#' stopifnot(map$x$project$layers[[1]]$style$fillColor == "#f59e0b")
#' @export
set_layer_style <- function(map, layer, style = list(), ...) {
  style <- merge_style(style, list(...))
  if (!length(style)) return(map)
  mutate_layer(map, layer, function(target) {
    current <- if (is.list(target$style)) target$style else default_layer_style()
    target$style <- merge_lists(current, style)
    target
  })
}

#' Symbolize an existing layer as a choropleth
#'
#' @param map A GeoLibre widget.
#' @param layer A layer id or layer name. The layer must carry inlined GeoJSON.
#' @param column Name of the numeric feature property to classify.
#' @param class_count Number of classes, clamped to between 2 and 12.
#' @param colormap A color ramp name from [color_ramp_names()].
#' @param scheme Classification scheme, `"equal-interval"` or `"quantile"`.
#' @return The modified widget.
#' @seealso [add_choropleth()] to add and symbolize in one call.
#' @examples
#' counties <- list(
#'   type = "FeatureCollection",
#'   features = list(
#'     list(
#'       type = "Feature", properties = list(pop = 10),
#'       geometry = list(type = "Point", coordinates = c(-77, 39))
#'     ),
#'     list(
#'       type = "Feature", properties = list(pop = 90),
#'       geometry = list(type = "Point", coordinates = c(-76, 40))
#'     )
#'   )
#' )
#' map <- geolibre() |>
#'   add_geojson(counties, name = "Counties") |>
#'   classify_layer("Counties", "pop", colormap = "reds")
#' stopifnot(map$x$project$layers[[1]]$style$vectorStyleProperty == "pop")
#' @export
classify_layer <- function(map, layer, column, class_count = 5, colormap = "viridis",
                           scheme = c("equal-interval", "quantile")) {
  check_string(column, "column")
  scheme <- check_choice(match.arg(scheme), CLASSIFICATION_SCHEMES, "scheme")
  values <- column_values(map, layer, column)
  fragment <- build_choropleth_style(
    values, column,
    class_count = class_count, colormap = colormap, scheme = scheme
  )
  set_layer_style(map, layer, fragment)
}

#' Sample a layer's feature properties
#'
#' Lets you discover what an inlined vector layer can be styled or filtered by
#' without reading every feature back.
#'
#' @param x A GeoLibre widget or a project list.
#' @param layer A layer id or layer name.
#' @return A named list mapping each property name to up to 25 distinct sample
#'   values, in first-seen order.
#' @examples
#' point <- list(
#'   type = "Feature", properties = list(name = "DC", pop = 700000),
#'   geometry = list(type = "Point", coordinates = c(-77, 39))
#' )
#' map <- geolibre() |> add_geojson(point, name = "Places")
#' layer_properties(map, "Places")
#' @export
layer_properties <- function(x, layer) {
  target <- inlined_layer(as_project_list(x), layer)
  samples <- list()
  for (feature in target$geojson$features) {
    properties <- if (is.list(feature)) feature$properties else NULL
    if (!is.list(properties)) next
    for (key in names(properties)) {
      seen <- samples[[key]]
      if (is.null(seen)) seen <- list()
      value <- properties[[key]]
      if (length(seen) < 25L && !any(vapply(seen, function(s) identical(s, value), logical(1)))) {
        seen[[length(seen) + 1L]] <- value
      }
      samples[[key]] <- seen
    }
  }
  samples
}

#' Read one feature property across a layer
#'
#' @param x A GeoLibre widget or a project list.
#' @param layer A layer id or layer name.
#' @param column The feature property name.
#' @return A list of the raw values, one per feature, with `NULL` where the
#'   property is absent.
#' @examples
#' point <- list(
#'   type = "Feature", properties = list(pop = 700000),
#'   geometry = list(type = "Point", coordinates = c(-77, 39))
#' )
#' map <- geolibre() |> add_geojson(point, name = "Places")
#' column_values(map, "Places", "pop")
#' @export
column_values <- function(x, layer, column) {
  check_string(column, "column")
  target <- inlined_layer(as_project_list(x), layer)
  features <- target$geojson$features
  values <- feature_column(features, column)
  present <- any(vapply(
    features,
    function(feature) {
      properties <- if (is.list(feature)) feature$properties else NULL
      is.list(properties) && column %in% names(properties)
    },
    logical(1)
  ))
  if (all(vapply(values, is.null, logical(1)))) {
    # A column that exists but is empty everywhere is a different problem from a
    # misspelled one, and only one of the two is worth retrying under a new name.
    if (present) {
      stop_geolibre("Column \"", column, "\" is empty in every feature.")
    }
    stop_geolibre("Column \"", column, "\" not found in any feature's properties.")
  }
  values
}

inlined_layer <- function(project, ref) {
  target <- project$layers[[find_layer_position(project, ref)]]
  if (!is.list(target$geojson) || !is.list(target$geojson$features)) {
    stop_geolibre(
      "Layer \"", target$name, "\" carries no inlined GeoJSON, so its features ",
      "cannot be read without fetching the source."
    )
  }
  target
}
