#' Create a GeoLibre widget
#'
#' Creates an `htmlwidget` that embeds the GeoLibre geographic information
#' system. The widget carries a `.geolibre.json` project, which the `add_*()`,
#' `set_*()`, and control functions build up with the pipe.
#'
#' @param project A GeoLibre project list, a path to a `.geolibre.json` file,
#'   or `NULL` for a new project.
#' @param center Optional initial `c(longitude, latitude)` map center.
#' @param zoom Optional initial zoom level.
#' @param basemap Optional basemap name from [basemaps()] or a MapLibre style
#'   JSON URL. Ignored when `project` is supplied, which carries its own.
#' @param name Project name recorded in the project file.
#' @param width,height Widget dimensions passed to [htmlwidgets::createWidget()].
#' @param app_url URL of a GeoLibre web deployment. It must support the
#'   `?embed=1` project bridge.
#' @param layout Application chrome to show: `"embed"` (compact controls),
#'   `"full"` (the complete desktop interface), or `"maponly"` (map only).
#' @param theme Application theme, `"light"` or `"dark"`.
#' @param map_only Deprecated. `TRUE` is equivalent to `layout = "maponly"`.
#' @param elementId Optional widget element ID.
#' @details The default hosted application requires internet access when the
#'   widget is displayed. Package installation, project construction, and file
#'   operations do not contact it. Set `app_url` or the `geolibre.app_url`
#'   option to use a self-hosted deployment.
#' @return An `htmlwidget` that can be modified with `add_*()` functions.
#' @seealso [add_geojson()], [set_view()], [save_project()]
#' @examples
#' map <- geolibre(center = c(-77.0369, 38.9072), zoom = 10, layout = "maponly")
#' stopifnot(inherits(map, "geolibre"))
#'
#' # A dark-themed map with the full application interface.
#' geolibre(basemap = "dark", layout = "full")
#' @export
geolibre <- function(project = NULL, center = NULL, zoom = NULL, basemap = NULL,
                     name = "Untitled Project", width = NULL, height = NULL,
                     app_url = getOption("geolibre.app_url", "https://web.geolibre.app/"),
                     layout = c("embed", "full", "maponly"), theme = c("light", "dark"),
                     map_only = FALSE, elementId = NULL) {
  check_http_url(app_url, "app_url")
  layout <- if (missing(layout)) {
    if (isTRUE(map_only)) "maponly" else "embed"
  } else {
    check_choice(match.arg(layout), c("embed", "full", "maponly"), "layout")
  }
  theme <- check_choice(match.arg(theme), c("light", "dark"), "theme")
  project <- if (is.null(project)) {
    new_project(
      name = name,
      center = center,
      zoom = zoom,
      basemap_url = if (is.null(basemap)) NULL else resolve_basemap(basemap)
    )
  } else {
    normalize_project(project)
  }
  htmlwidgets::createWidget(
    name = "geolibre",
    x = list(
      project = project,
      appUrl = app_url,
      layout = layout,
      theme = theme
    ),
    width = width,
    height = height,
    package = "geolibre",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultHeight = 700,
      padding = 0,
      browser.fill = TRUE,
      viewer.fill = TRUE,
      browser.padding = 0,
      viewer.padding = 0
    )
  )
}

normalize_project <- function(project) {
  if (is.null(project)) return(new_project())
  if (is_scalar_string(project)) return(load_project(project))
  if (!is.list(project)) {
    stop_geolibre("`project` must be a list, JSON string, or file path.")
  }
  required <- c("version", "name", "mapView")
  missing <- setdiff(required, names(project))
  if (length(missing)) {
    stop_geolibre("Invalid project; missing: ", paste(missing, collapse = ", "))
  }
  if (!is_scalar_string(project$version)) {
    stop_geolibre("Invalid project; `version` must be a single string.")
  }
  if (!is_scalar_string(project$name)) {
    stop_geolibre("Invalid project; `name` must be a single string.")
  }
  if (!is.list(project$mapView)) {
    stop_geolibre("Invalid project; `mapView` must be a list.")
  }
  if (is.null(project$layers)) project$layers <- empty_array()
  if (!is.list(project$layers)) {
    stop_geolibre("Invalid project; `layers` must be a list.")
  }
  # Drop malformed entries, such as the `null` a hand-edited project file can
  # carry, so a layer's position in this list is also its position in the draw
  # order. Everything that resolves a layer reference then subscripts one list.
  project$layers <- unname(Filter(is.list, project$layers))
  project
}

widget_project <- function(map) {
  if (!inherits(map, "geolibre")) {
    stop_geolibre("`map` must be a GeoLibre widget.")
  }
  map$x$project
}

set_widget_project <- function(map, project) {
  map$x$project <- project
  map
}

# Apply a project mutation to a widget, returning the modified widget. Every
# `add_*()` / `set_*()` function funnels through here so widget plumbing lives in
# one place.
update_project <- function(map, mutate) {
  set_widget_project(map, mutate(widget_project(map)))
}

# Accept either a widget or a bare project list, for the read-only helpers.
as_project_list <- function(x) {
  if (inherits(x, "geolibre")) return(widget_project(x))
  normalize_project(x)
}

append_layer <- function(map, layer) {
  update_project(map, function(project) {
    reject_reserved_name(layer$name)
    project$layers <- c(project$layers, list(layer))
    project
  })
}

# The swipe control reads `"__basemap__"` as the basemap rather than consulting
# the layer list, so a layer wearing that name would be unaddressable there.
reject_reserved_name <- function(name) {
  if (is_scalar_string(name) && identical(name, BASEMAP_LAYER_ID)) {
    stop_geolibre(
      "\"", BASEMAP_LAYER_ID, "\" is reserved for the basemap and cannot name a layer."
    )
  }
  invisible(TRUE)
}

project_layers <- function(project) {
  layers <- project$layers
  if (!is.list(layers)) return(list())
  Filter(is.list, layers)
}

# The positions of a project's usable layers, with their ids and names. The
# positions index `project$layers` itself, so a caller can subscript that list
# directly even if a hand-built project slipped a malformed entry past
# `normalize_project()`.
layer_lookup <- function(project) {
  layers <- if (is.list(project$layers)) project$layers else list()
  positions <- which(vapply(layers, is.list, logical(1)))
  field <- function(key) {
    vapply(
      positions,
      function(position) {
        value <- layers[[position]][[key]]
        if (is_scalar_string(value)) value else NA_character_
      },
      character(1)
    )
  }
  list(positions = positions, ids = field("id"), names = field("name"))
}

# Resolve a layer reference to its position in the project's draw order. An exact
# id match wins outright, so a layer whose *name* equals another layer's *id*
# cannot shadow it; name matching is tried next, exact first, then
# case-insensitively. A name several layers share is an error rather than an
# arbitrary pick.
find_layer_position <- function(project, ref) {
  if (!is_scalar_string(ref)) {
    stop_geolibre("`layer` must be a single layer id or layer name.")
  }
  lookup <- layer_lookup(project)
  if (!length(lookup$positions)) {
    stop_geolibre("No layer matches \"", ref, "\". This project has no layers.")
  }
  hit <- which(lookup$ids == ref)
  if (length(hit)) return(lookup$positions[[hit[[1]]]])
  for (matches in list(which(lookup$names == ref),
                       which(tolower(lookup$names) == tolower(ref)))) {
    if (length(matches) == 1L) return(lookup$positions[[matches[[1]]]])
    if (length(matches) > 1L) {
      stop_geolibre(
        length(matches), " layers are named \"", ref,
        "\"; reference it by id instead (ids: ",
        paste(lookup$ids[matches], collapse = ", "), ")."
      )
    }
  }
  stop_geolibre(
    "No layer matches \"", ref, "\". Layers in this project: ",
    paste0("\"", lookup$names, "\"", collapse = ", ")
  )
}

resolve_layer_id <- function(project, ref) {
  project_layers(project)[[find_layer_position(project, ref)]]$id
}

# Resolve several references to ids, passing the basemap pseudo-id through.
resolve_layer_ids <- function(project, refs) {
  if (is.null(refs) || !length(refs)) return(character(0))
  refs <- as.character(unlist(refs, use.names = FALSE))
  vapply(
    refs,
    function(ref) if (identical(ref, BASEMAP_LAYER_ID)) ref else resolve_layer_id(project, ref),
    character(1),
    USE.NAMES = FALSE
  )
}

# Apply a mutation to one resolved layer, in place in the project's layer list.
mutate_layer <- function(map, ref, mutate) {
  update_project(map, function(project) {
    position <- find_layer_position(project, ref)
    project$layers[[position]] <- mutate(project$layers[[position]])
    project
  })
}
