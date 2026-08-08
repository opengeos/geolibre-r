# On-map controls: legends, colorbars, and the split-map swipe slider. Each is a
# thin wrapper over one of the application's built-in map-control plugins,
# configured through the project's `plugins` block and replayed on load.

#' Add a legend to the map
#'
#' Supply the legend entries exactly one of three ways: a built-in preset
#' (`builtin`), a named vector or list of label-to-color pairs (`legend`), or
#' parallel `labels` and `colors` vectors. Each call adds another legend, so a
#' map can carry several at once.
#'
#' @param map A GeoLibre widget.
#' @param title Legend title. Defaults to `"Legend"`, or the preset's own title
#'   when `builtin` is supplied without one.
#' @param legend A named vector or list mapping label to CSS color. Order is
#'   preserved.
#' @param labels Item labels, paired position-wise with `colors`.
#' @param colors Item CSS colors, paired position-wise with `labels`.
#' @param builtin A built-in preset name from [builtin_legend_names()].
#' @param position Corner for the legend: `"top-left"`, `"top-right"`,
#'   `"bottom-left"`, or `"bottom-right"`.
#' @param shape Swatch shape for every item: `"square"`, `"circle"`, or `"line"`.
#' @return The modified widget.
#' @seealso [add_colorbar()] for continuous rasters, [builtin_legend_names()]
#' @examples
#' map <- geolibre() |>
#'   add_legend(
#'     "Land cover",
#'     legend = c(Water = "#466b9f", Forest = "#1c5f2c"),
#'     position = "bottom-left"
#'   )
#'
#' # A built-in preset carries its own title and colors.
#' geolibre() |> add_legend(builtin = "nlcd")
#' @export
add_legend <- function(map, title = NULL, legend = NULL, labels = NULL, colors = NULL,
                       builtin = NULL, position = c("bottom-left", "bottom-right",
                                                    "top-left", "top-right"),
                       shape = c("square", "circle", "line")) {
  position <- check_choice(match.arg(position), CONTROL_POSITIONS, "position")
  shape <- check_choice(match.arg(shape), LEGEND_SHAPES, "shape")
  # The three ways to supply entries are mutually exclusive; reject a combination
  # rather than letting one silently win by check order.
  sources <- c(
    !is.null(builtin),
    !is.null(legend),
    !is.null(labels) || !is.null(colors)
  )
  if (sum(sources) > 1L) {
    stop_geolibre(
      "Provide legend entries through exactly one of `builtin`, `legend`, ",
      "or `labels` and `colors`."
    )
  }
  if (!is.null(builtin)) {
    preset <- get_builtin_legend(builtin)
    labels <- preset$labels
    colors <- preset$colors
    if (is.null(title)) title <- preset$title
  } else if (!is.null(legend)) {
    if (is.null(names(legend)) || any(!nzchar(names(legend)))) {
      stop_geolibre("`legend` must be a named vector or list of label = color pairs.")
    }
    labels <- names(legend)
    colors <- as.character(unlist(legend, use.names = FALSE))
  } else if (!is.null(labels) || !is.null(colors)) {
    if (is.null(labels) || is.null(colors)) {
      stop_geolibre("`labels` and `colors` must be provided together.")
    }
    labels <- as.character(labels)
    colors <- as.character(colors)
    if (length(labels) != length(colors)) {
      stop_geolibre(
        "`labels` and `colors` must have the same length (",
        length(labels), " != ", length(colors), ")."
      )
    }
  } else {
    stop_geolibre(
      "Provide legend entries through `builtin`, `legend`, or `labels` and `colors`."
    )
  }
  if (!length(labels)) stop_geolibre("The legend has no items.")
  if (is.null(title)) title <- "Legend"
  check_string(title, "title")

  items <- lapply(
    seq_along(labels),
    function(i) list(label = labels[[i]], color = colors[[i]], shape = shape)
  )
  entry <- legend_gui_entry(title, items, position)
  update_project(map, function(project) {
    merge_components_state(
      project, "legend",
      function(existing) legend_gui_state(entry, existing = existing)
    )
  })
}

#' Add a colorbar to the map
#'
#' Renders a gradient with minimum and maximum ticks, from either a named color
#' ramp or an explicit list of CSS colors. Each call adds another colorbar.
#'
#' @param map A GeoLibre widget.
#' @param colormap A color ramp name from [color_ramp_names()]. Ignored when
#'   `colors` is supplied.
#' @param vmin Value at the low end of the colorbar.
#' @param vmax Value at the high end of the colorbar.
#' @param label Title shown alongside the colorbar.
#' @param units Units suffix shown with the values.
#' @param colors Optional character vector of CSS colors defining a custom
#'   gradient, used instead of `colormap`.
#' @param orientation `"vertical"` or `"horizontal"`.
#' @param position Corner for the colorbar: `"top-left"`, `"top-right"`,
#'   `"bottom-left"`, or `"bottom-right"`.
#' @return The modified widget.
#' @seealso [add_legend()] for categorical classes
#' @examples
#' map <- geolibre() |>
#'   add_raster("https://example.com/dem.tif", bands = 1, colormap = "terrain") |>
#'   add_colorbar(
#'     colormap = "terrain", vmin = 0, vmax = 3000,
#'     label = "Elevation", units = "m"
#'   )
#' @export
add_colorbar <- function(map, colormap = "viridis", vmin = 0, vmax = 1, label = "",
                         units = "", colors = NULL,
                         orientation = c("vertical", "horizontal"),
                         position = c("bottom-right", "bottom-left",
                                      "top-left", "top-right")) {
  orientation <- check_choice(match.arg(orientation), ORIENTATIONS, "orientation")
  position <- check_choice(match.arg(position), CONTROL_POSITIONS, "position")
  check_string(colormap, "colormap")
  vmin <- check_number(vmin, "vmin")
  vmax <- check_number(vmax, "vmax")
  # The application's normalizer only repairs vmin == vmax; an inverted range
  # would otherwise render a reversed gradient, so reject it here.
  if (vmin >= vmax) {
    stop_geolibre("`vmin` (", vmin, ") must be less than `vmax` (", vmax, ").")
  }
  if (!is_scalar_string(label)) stop_geolibre("`label` must be a single string.")
  if (!is_scalar_string(units)) stop_geolibre("`units` must be a single string.")
  if (!is.null(colors)) {
    colors <- as.character(unlist(colors, use.names = FALSE))
    if (!length(colors)) {
      stop_geolibre("`colors` must be a non-empty character vector when supplied.")
    }
  }
  entry <- colorbar_gui_entry(
    mode = if (is.null(colors)) "named" else "custom",
    colormap = colormap,
    custom_colors = if (is.null(colors)) "" else paste(colors, collapse = ", "),
    vmin = vmin,
    vmax = vmax,
    label = label,
    units = units,
    orientation = orientation,
    position = position
  )
  update_project(map, function(project) {
    merge_components_state(
      project, "colorbar",
      function(existing) colorbar_gui_state(entry, existing = existing)
    )
  })
}

#' Add a colorbar from a named color ramp
#'
#' [add_colorbar()] with `colormap` in the leading position, for parity with the
#' Python API.
#'
#' @inheritParams add_colorbar
#' @param ... Forwarded to [add_colorbar()], for example `units`, `orientation`,
#'   or `position`.
#' @return The modified widget.
#' @examples
#' geolibre() |> add_colormap("plasma", vmin = 0, vmax = 100, label = "Index")
#' @export
add_colormap <- function(map, colormap = "viridis", vmin = 0, vmax = 1, label = "", ...) {
  add_colorbar(map, colormap = colormap, vmin = vmin, vmax = vmax, label = label, ...)
}

#' Add a split-map comparison slider
#'
#' Enables the Layer Swipe control, which clips one set of layers to one side of
#' a draggable slider and another set to the other, for before-and-after
#' comparisons.
#'
#' @param map A GeoLibre widget.
#' @param left_layers Layer ids or names shown on the left or top of the slider.
#'   The string `"__basemap__"` selects the basemap.
#' @param right_layers Layer ids or names shown on the right or bottom.
#' @param orientation `"vertical"` to move the slider left and right, or
#'   `"horizontal"` to move it up and down.
#' @param position Initial slider position as a percentage from 0 to 100.
#' @param control_position Corner for the swipe panel: `"top-left"`,
#'   `"top-right"`, `"bottom-left"`, or `"bottom-right"`.
#' @return The modified widget.
#' @examples
#' map <- geolibre() |>
#'   add_raster("https://example.com/before.tif", name = "Before") |>
#'   add_raster("https://example.com/after.tif", name = "After") |>
#'   split_map("Before", "After")
#' stopifnot(length(map$x$project$plugins$settings) == 1L)
#' @export
split_map <- function(map, left_layers = NULL, right_layers = NULL,
                      orientation = c("vertical", "horizontal"), position = 50,
                      control_position = c("top-left", "top-right",
                                           "bottom-left", "bottom-right")) {
  orientation <- check_choice(match.arg(orientation), ORIENTATIONS, "orientation")
  control_position <- check_choice(
    match.arg(control_position), CONTROL_POSITIONS, "control_position"
  )
  position <- clamp(check_number(position, "position"), 0, 100)
  update_project(map, function(project) {
    set_plugin_state(
      project,
      SWIPE_PLUGIN_ID,
      swipe_state(
        left_layers = resolve_layer_ids(project, left_layers),
        right_layers = resolve_layer_ids(project, right_layers),
        orientation = orientation,
        position = position
      ),
      position = control_position
    )
  })
}
