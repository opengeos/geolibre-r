# Color ramps and classification helpers for data-driven vector symbology.
# The anchor colors mirror `VECTOR_COLOR_RAMPS` in the application's core
# package, so a choropleth built from R renders exactly as one built in the UI.

VECTOR_COLOR_RAMPS <- list(
  viridis = c("#440154", "#31688e", "#35b779", "#fde725"),
  plasma = c("#0d0887", "#9c179e", "#ed7953", "#f0f921"),
  inferno = c("#000004", "#781c6d", "#ed6925", "#fcffa4"),
  magma = c("#000004", "#721f81", "#f1605d", "#fcfdbf"),
  cividis = c("#00204d", "#575d6d", "#a59c74", "#ffea46"),
  turbo = c("#30123b", "#4777ef", "#1ccfd0", "#b9e642", "#fb8022", "#7a0403"),
  spectral = c("#9e0142", "#f46d43", "#ffffbf", "#66c2a5", "#5e4fa2"),
  blues = c("#eff6ff", "#93c5fd", "#2563eb", "#1e3a8a"),
  greens = c("#f0fdf4", "#86efac", "#16a34a", "#14532d"),
  oranges = c("#fff7ed", "#fdba74", "#f97316", "#7c2d12"),
  reds = c("#fff5f0", "#fcae91", "#fb6a4a", "#cb181d", "#67000d"),
  purples = c("#fcfbfd", "#bcbddc", "#807dba", "#54278f", "#3f007d"),
  terrain = c("#333399", "#21bcb3", "#79d05a", "#e8e85a", "#a87b54", "#ffffff"),
  rdylgn = c("#a50026", "#f46d43", "#ffffbf", "#66bd63", "#006837"),
  rdylbu = c("#a50026", "#f46d43", "#ffffbf", "#74add1", "#313695"),
  rdbu = c("#b2182b", "#ef8a62", "#f7f7f7", "#67a9cf", "#2166ac"),
  coolwarm = c("#3b4cc0", "#7b9ff9", "#dddcdc", "#f49a7b", "#b40426"),
  jet = c("#000080", "#0000ff", "#00ffff", "#ffff00", "#ff0000", "#800000"),
  greys = c("#ffffff", "#bdbdbd", "#636363", "#000000"),
  gray = c("#000000", "#ffffff")
)

DEFAULT_COLOR_RAMP <- "viridis"

CLASSIFICATION_SCHEMES <- c("equal-interval", "quantile")

#' Available color ramp names
#'
#' The ramp names accepted by [add_choropleth()], [classify_layer()], and
#' [add_colorbar()].
#'
#' @return A character vector of ramp names.
#' @examples
#' color_ramp_names()
#' @export
color_ramp_names <- function() {
  names(VECTOR_COLOR_RAMPS)
}

#' Anchor colors of a color ramp
#'
#' @param name A ramp name from [color_ramp_names()]. An unknown name falls back
#'   to `"viridis"`, matching the application's own lookup.
#' @return A character vector of `#rrggbb` colors.
#' @examples
#' get_color_ramp("viridis")
#' get_color_ramp("blues")
#' @export
get_color_ramp <- function(name = "viridis") {
  if (!is_scalar_string(name) || !(name %in% names(VECTOR_COLOR_RAMPS))) {
    return(VECTOR_COLOR_RAMPS[[DEFAULT_COLOR_RAMP]])
  }
  VECTOR_COLOR_RAMPS[[name]]
}

parse_hex <- function(value) {
  numeric <- strtoi(sub("^#", "", value), base = 16L)
  c(
    bitwAnd(bitwShiftR(numeric, 16L), 255L),
    bitwAnd(bitwShiftR(numeric, 8L), 255L),
    bitwAnd(numeric, 255L)
  )
}

to_hex <- function(channels) {
  paste0("#", paste(sprintf("%02x", as.integer(channels)), collapse = ""))
}

interpolate_hex <- function(start, end, ratio) {
  from <- parse_hex(start)
  to <- parse_hex(end)
  to_hex(round(from + (to - from) * ratio))
}

#' Sample a color ramp into evenly spaced colors
#'
#' Mirrors the application's ramp interpolation, so a palette generated here
#' matches the one the Style panel would compute.
#'
#' @param name A ramp name from [color_ramp_names()].
#' @param count Number of colors to produce.
#' @return A character vector of `count` `#rrggbb` colors.
#' @examples
#' interpolate_ramp_colors("viridis", 5)
#' @export
interpolate_ramp_colors <- function(name = "viridis", count = 5) {
  count <- check_integer(count, "count", min = 1L)
  colors <- get_color_ramp(name)
  if (count <= 1L) return(colors[[length(colors)]])
  vapply(
    seq_len(count),
    function(index) {
      scaled <- ((index - 1L) / (count - 1L)) * (length(colors) - 1L)
      lower <- floor(scaled)
      upper <- min(length(colors) - 1L, ceiling(scaled))
      interpolate_hex(colors[[lower + 1L]], colors[[upper + 1L]], scaled - lower)
    },
    character(1)
  )
}

equal_interval_breaks <- function(minimum, maximum, count) {
  vapply(
    seq_len(count),
    function(index) {
      fraction <- if (count == 1L) 0 else (index - 1L) / (count - 1L)
      minimum + (maximum - minimum) * fraction
    },
    numeric(1)
  )
}

quantile_breaks <- function(values, count) {
  if (count <= 0L || !length(values)) return(numeric(0))
  sorted <- sort(values)
  vapply(
    seq_len(count),
    function(index) {
      position <- if (count == 1L) 0 else ((index - 1L) / (count - 1L)) * (length(sorted) - 1L)
      lower <- floor(position)
      upper <- min(length(sorted) - 1L, ceiling(position))
      ratio <- position - lower
      sorted[[lower + 1L]] + (sorted[[upper + 1L]] - sorted[[lower + 1L]]) * ratio
    },
    numeric(1)
  )
}

# Coerce a column of raw feature-property values to the finite numbers the
# graduated classifier works on, dropping anything non-numeric the way the
# application's `Number.isFinite` filter does.
finite_numbers <- function(values) {
  numeric <- suppressWarnings(as.numeric(unlist(
    lapply(values, function(value) if (is.null(value) || !length(value)) NA else value[[1]])
  )))
  numeric[is.finite(numeric)]
}

# Build graduated `vectorStyleStops`. Mirrors `createGraduatedStops` in the app:
# class counts clamp to 2-12, non-numeric values are dropped, and the stop colors
# are sampled from the ramp.
graduated_stops <- function(values, class_count = 5, color_ramp = "viridis",
                            classification_scheme = "equal-interval") {
  check_choice(classification_scheme, CLASSIFICATION_SCHEMES, "scheme")
  count <- as.integer(clamp(check_integer(class_count, "class_count", min = 1L), 2L, 12L))
  colors <- interpolate_ramp_colors(color_ramp, count)
  numeric <- finite_numbers(values)
  if (!length(numeric)) {
    return(lapply(seq_along(colors), function(i) list(value = i - 1L, color = colors[[i]])))
  }
  minimum <- min(numeric)
  maximum <- max(numeric)
  if (minimum == maximum) {
    return(list(list(value = minimum, color = colors[[length(colors)]])))
  }
  breaks <- if (identical(classification_scheme, "quantile")) {
    quantile_breaks(numeric, count)
  } else {
    equal_interval_breaks(minimum, maximum, count)
  }
  lapply(
    seq_along(breaks),
    function(i) list(value = as.numeric(signif(breaks[[i]], 8L)), color = colors[[i]])
  )
}

# The `vectorStyle*` style fragment for a graduated (choropleth) symbology.
build_choropleth_style <- function(values, column, class_count = 5,
                                   colormap = "viridis", scheme = "equal-interval") {
  if (!length(finite_numbers(values))) {
    stop_geolibre(
      "Column \"", column,
      "\" must contain at least one numeric value for a graduated choropleth."
    )
  }
  list(
    vectorStyleMode = "graduated",
    vectorStyleProperty = column,
    vectorStyleClassCount = as.integer(clamp(class_count, 2L, 12L)),
    vectorStyleColorRamp = colormap,
    vectorStyleClassificationScheme = scheme,
    vectorStyleStops = graduated_stops(
      values,
      class_count = class_count,
      color_ramp = colormap,
      classification_scheme = scheme
    )
  )
}
