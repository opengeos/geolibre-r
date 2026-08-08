# Builders for GeoLibre project (`.geolibre.json`) lists and their layers.
#
# The shapes here mirror the TypeScript interfaces in the application's core
# package (`types.ts`, `project.ts`). Keeping these builders faithful to those
# interfaces is what lets the embedded app load a project produced entirely
# from R.

PROJECT_VERSION <- "0.2.0"

# Mirror of DEFAULT_LAYER_STYLE in the app's core package. The app fills in any
# missing field on load, so a layer only needs to override what differs, but
# carrying the full default keeps round-tripped projects stable.
default_layer_style <- function() {
  list(
    minZoom = 0,
    maxZoom = 24,
    fillColor = "#3b82f6",
    strokeColor = "#1e40af",
    strokeWidth = 2,
    fillOpacity = 0.6,
    circleRadius = 6,
    textColor = "#111827",
    textHaloColor = "#ffffff",
    textHaloWidth = 2,
    textSize = 16,
    extrusionEnabled = FALSE,
    extrusionColor = "#3b82f6",
    extrusionOpacity = 0.8,
    extrusionHeightProperty = "height",
    extrusionHeightScale = 1,
    extrusionBase = 0,
    extrusionAdvancedStyleEnabled = FALSE,
    extrusionColorExpression = "",
    extrusionHeightExpression = "",
    vectorStyleMode = "single",
    vectorStyleProperty = "",
    vectorStyleClassCount = 5,
    vectorStyleColorRamp = "viridis",
    vectorStyleClassificationScheme = "equal-interval",
    vectorStyleStops = list(
      list(value = 0, color = "#dbeafe"),
      list(value = 1, color = "#2563eb")
    ),
    vectorStyleExpression = "",
    pointRenderer = "single",
    heatmapRadius = 30,
    heatmapIntensity = 1,
    clusterRadius = 50,
    clusterMaxZoom = 14,
    rasterBrightnessMin = 0,
    rasterBrightnessMax = 1,
    rasterSaturation = 0,
    rasterContrast = 0,
    rasterHueRotate = 0
  )
}

# Mirror of DEFAULT_PROJECT_PREFERENCES in the app's core package.
default_project_preferences <- function() {
  list(
    map = list(
      restrictBounds = FALSE,
      bounds = c(-180, -85, 180, 85),
      minZoom = 0,
      maxZoom = 24,
      maxPitch = 85,
      renderWorldCopies = TRUE
    ),
    environmentVariables = empty_array()
  )
}

# The app's default camera (`createDefaultMapView`).
default_map_view <- function() {
  list(center = c(-100, 40), zoom = 2, bearing = 0, pitch = 0)
}

new_project <- function(name = "Untitled Project", center = NULL, zoom = NULL,
                        basemap_url = NULL) {
  view <- default_map_view()
  if (!is.null(center)) view$center <- check_lnglat(center)
  if (!is.null(zoom)) view$zoom <- clamp(check_number(zoom, "zoom"), 0, 24)
  list(
    version = PROJECT_VERSION,
    name = check_string(name, "name"),
    mapView = view,
    basemapStyleUrl = if (is.null(basemap_url)) DEFAULT_BASEMAP else basemap_url,
    basemapVisible = TRUE,
    basemapOpacity = 1,
    layers = empty_array(),
    styles = empty_object(),
    preferences = default_project_preferences(),
    metadata = empty_object()
  )
}

layer_base <- function(name, layer_type, style = list()) {
  list(
    id = new_uuid(),
    name = name,
    type = layer_type,
    visible = TRUE,
    opacity = 1,
    style = merge_lists(default_layer_style(), style),
    metadata = empty_object()
  )
}

geojson_layer <- function(name, data, source_url = NULL, style = list()) {
  layer <- layer_base(name, "geojson", style)
  source <- list(type = "geojson")
  if (!is.null(source_url)) {
    source$url <- source_url
    layer$sourcePath <- source_url
  }
  layer$source <- source
  layer$geojson <- data
  layer
}

tile_layer <- function(name, url, tile_size = 256, attribution = NULL, style = list()) {
  layer <- layer_base(name, "xyz", style)
  source <- list(
    type = "raster",
    tiles = as_json_array(url),
    tileSize = tile_size,
    url = url
  )
  if (!is.null(attribution)) source$attribution <- attribution
  layer$source <- source
  layer$metadata <- list(sourceKind = "xyz-url")
  layer
}

cog_layer <- function(name, url, bands = NULL, colormap = NULL, rescale = NULL,
                      style = list()) {
  layer <- layer_base(name, "cog", style)
  raster_state <- list()
  if (!is.null(rescale)) raster_state$rescale <- lapply(rescale, function(range) unname(range))
  if (!is.null(bands)) {
    raster_state$bands <- as_json_array(as.integer(bands))
    raster_state$mode <- if (length(bands) >= 3L) "rgb" else "single"
  }
  if (!is.null(colormap)) raster_state$colormap <- colormap
  layer$source <- list(type = "raster", url = url)
  layer$metadata <- list(
    customLayerType = "raster",
    externalDeckLayer = TRUE,
    externalNativeLayer = TRUE,
    identifiable = FALSE,
    nativeLayerIds = as_json_array(layer$id),
    panelCollapsed = TRUE,
    rasterOverlayMode = "interleaved",
    rasterSource = "url",
    rasterState = if (length(raster_state)) raster_state else empty_object(),
    sourceIds = empty_array(),
    sourceKind = "maplibre-gl-raster"
  )
  layer$sourcePath <- url
  layer
}

# Normalize a WMS version to the "1.1.1"/"1.3.0" pair the builder emits.
normalize_wms_version <- function(version) {
  if (!is_scalar_string(version)) return("1.1.1")
  if (startsWith(trimws(version), "1.3")) "1.3.0" else "1.1.1"
}

wms_layer <- function(name, endpoint, layers, styles = "", image_format = "image/png",
                      transparent = TRUE, tile_size = 256, version = "1.1.1",
                      style = list()) {
  wms_version <- normalize_wms_version(version)
  params <- list(
    SERVICE = "WMS",
    REQUEST = "GetMap",
    VERSION = wms_version,
    LAYERS = layers,
    STYLES = styles,
    FORMAT = image_format,
    TRANSPARENT = if (isTRUE(transparent)) "TRUE" else "FALSE"
  )
  params[[if (identical(wms_version, "1.3.0")) "CRS" else "SRS"]] <- "EPSG:3857"
  params$BBOX <- "{bbox-epsg-3857}"
  params$WIDTH <- as.character(tile_size)
  params$HEIGHT <- as.character(tile_size)
  tile_url <- append_query(endpoint, params)
  layer <- layer_base(name, "wms", style)
  layer$source <- list(
    type = "raster",
    tiles = as_json_array(tile_url),
    tileSize = tile_size,
    url = endpoint,
    layers = layers,
    styles = styles,
    format = image_format,
    transparent = isTRUE(transparent),
    version = wms_version
  )
  layer$metadata <- list(service = "wms")
  layer
}

wmts_layer <- function(name, url, tile_size = 256, style = list()) {
  layer <- layer_base(name, "wmts", style)
  layer$source <- list(
    type = "raster",
    tiles = as_json_array(url),
    tileSize = tile_size,
    url = url
  )
  layer$metadata <- list(service = "wmts")
  layer
}

wfs_getfeature_url <- function(endpoint, type_name, version = "2.0.0",
                               output_format = "application/json",
                               srs_name = "EPSG:4326", max_features = NULL) {
  is_wfs2 <- startsWith(version, "2")
  params <- list(
    service = "WFS",
    request = "GetFeature",
    version = version
  )
  params[[if (is_wfs2) "typeNames" else "typeName"]] <- type_name
  params$outputFormat <- output_format
  if (is_scalar_string(srs_name) && nzchar(srs_name)) params$srsName <- srs_name
  if (!is.null(max_features)) {
    params[[if (is_wfs2) "count" else "maxFeatures"]] <- as.character(as.integer(max_features))
  }
  append_query(endpoint, params)
}

vector_layer <- function(name, url, render_mode = "geojson", data_format = NULL,
                         source_layer = NULL, picker = NULL, ingest_mode = NULL,
                         style = list()) {
  check_choice(render_mode, c("geojson", "tiles"), "render_mode")
  if (!is.null(ingest_mode)) check_choice(ingest_mode, c("table", "stream"), "ingest_mode")
  is_tiles <- identical(render_mode, "tiles")
  layer <- layer_base(name, if (is_tiles) "vector-tiles" else "geojson", style)
  layer$source <- list(type = if (is_tiles) "vector" else "geojson", url = url)
  vector_state <- list(renderMode = render_mode)
  if (!is.null(data_format)) vector_state$format <- data_format
  if (!is.null(source_layer)) vector_state$sourceLayer <- source_layer
  if (!is.null(picker)) vector_state$picker <- isTRUE(picker)
  if (!is.null(ingest_mode)) vector_state$ingestMode <- ingest_mode
  layer$metadata <- list(
    sourceKind = "maplibre-gl-vector",
    externalNativeLayer = TRUE,
    # The in-browser vector control owns its layers' paint; the core sync must
    # not re-apply it.
    controlOwnsPaint = TRUE,
    identifiable = FALSE,
    # Empty is safe here: the restore path detects the layer from `sourceKind`
    # plus `externalNativeLayer` and loads it through the control, which then
    # fills in the real native layer ids.
    nativeLayerIds = empty_array(),
    sourceIds = as_json_array(paste0(layer$id, "-source")),
    vectorSource = "url",
    vectorState = vector_state
  )
  layer$sourcePath <- url
  layer
}

vector_tiles_layer <- function(name, url, source_layers = NULL, source_layer = NULL,
                               style = list()) {
  layer <- layer_base(name, "vector-tiles", style)
  source <- list(type = "vector", url = url)
  if (length(source_layers)) {
    if (!is.null(source_layer)) {
      warning(
        "`source_layer` is ignored when `source_layers` is supplied; pass one or the other.",
        call. = FALSE
      )
    }
    source$sourceLayers <- as_json_array(source_layers)
  } else if (!is.null(source_layer)) {
    source$sourceLayer <- source_layer
  }
  layer$source <- source
  layer
}

pmtiles_layer <- function(name, url, tile_type = "vector", source_layers = NULL,
                          style = list()) {
  check_choice(tile_type, c("vector", "raster"), "tile_type")
  layer <- layer_base(name, "pmtiles", style)
  source_id <- layer$id
  layer$source <- list(
    type = if (identical(tile_type, "raster")) "raster" else "vector",
    url = url,
    sourceId = source_id,
    sourceLayers = as_json_array(source_layers),
    tileType = tile_type
  )
  # `nativeLayerIds` must be non-empty: the app gates external native layers on
  # its length, and a "pmtiles" layer has no fallback dispatch, so an empty list
  # means the source is never added. These placeholders match what the app would
  # otherwise compute.
  native_ids <- if (identical(tile_type, "raster")) paste0(source_id, "-raster") else source_id
  layer$metadata <- list(
    sourceKind = "pmtiles-url",
    externalNativeLayer = TRUE,
    sourceId = source_id,
    tileType = tile_type,
    sourceLayers = as_json_array(source_layers),
    nativeLayerIds = as_json_array(native_ids)
  )
  layer$sourcePath <- url
  layer
}

three_d_tiles_layer <- function(name, url, altitude_offset = 0,
                                request_headers = NULL, style = list()) {
  layer <- layer_base(name, "3d-tiles", style)
  source_id <- layer$id
  source <- list(
    type = "3d-tiles",
    url = url,
    sourceId = source_id,
    altitudeOffset = altitude_offset
  )
  if (length(request_headers)) source$requestHeaders <- request_headers
  layer$source <- source
  layer$metadata <- list(
    sourceKind = "3d-tiles-url",
    externalNativeLayer = TRUE,
    customLayerType = "3d-tiles",
    identifiable = FALSE,
    sourceId = source_id,
    nativeLayerIds = as_json_array(source_id),
    altitudeOffset = altitude_offset,
    panelCollapsed = TRUE,
    status = "loading"
  )
  layer$sourcePath <- url
  layer
}

video_layer <- function(name, urls, coordinates, style = list()) {
  if (!is.character(urls) || !length(urls) || any(is.na(urls)) || any(!nzchar(urls))) {
    stop_geolibre("`urls` must be one or more non-empty strings.")
  }
  if (any(!grepl("^https://", tolower(urls)))) {
    stop_geolibre("Video URLs must start with https:// (the browser CSP blocks http://).")
  }
  corners <- normalize_corners(coordinates)
  lngs <- vapply(corners, function(corner) corner[[1]], numeric(1))
  lats <- vapply(corners, function(corner) corner[[2]], numeric(1))
  layer <- layer_base(name, "video", style)
  layer$source <- list(
    type = "video",
    urls = as_json_array(urls),
    coordinates = lapply(corners, function(corner) unname(corner))
  )
  # Persist the corner bbox so "Zoom to layer" works; a video source exposes no
  # bounds of its own.
  layer$metadata <- list(
    sourceKind = "video-url",
    bounds = c(min(lngs), min(lats), max(lngs), max(lats))
  )
  layer$sourcePath <- urls[[1]]
  layer
}

# Accept the four video corners as a list of `c(lng, lat)` pairs or as a 4x2
# matrix / data frame of longitude and latitude columns.
normalize_corners <- function(coordinates) {
  if (is.matrix(coordinates) || is.data.frame(coordinates)) {
    coordinates <- as.matrix(coordinates)
    coordinates <- lapply(seq_len(nrow(coordinates)), function(i) as.numeric(coordinates[i, ]))
  }
  if (!is.list(coordinates) || length(coordinates) != 4L) {
    stop_geolibre(
      "`coordinates` must be four c(longitude, latitude) corners in top-left, ",
      "top-right, bottom-right, bottom-left order."
    )
  }
  lapply(coordinates, function(corner) check_lnglat(corner, "coordinates"))
}

# -- plugin (map control) state ----------------------------------------------
# The split-map (swipe), legend, and colorbar helpers are thin wrappers over the
# app's built-in map-control plugins, configured through the project's `plugins`
# block.

CONTROL_POSITIONS <- c("top-left", "top-right", "bottom-left", "bottom-right")
ORIENTATIONS <- c("vertical", "horizontal")
LEGEND_SHAPES <- c("square", "circle", "line")

SWIPE_PLUGIN_ID <- "maplibre-gl-swipe"
COMPONENTS_PLUGIN_ID <- "maplibre-gl-components"

# The pseudo-id the swipe control uses for the basemap.
BASEMAP_LAYER_ID <- "__basemap__"

# Plugins the app activates by default. When a project carries a `plugins`
# block, the app deactivates any active plugin missing from `activePluginIds`,
# so a block built from R must seed these or it would tear down the layer
# control and the deck.gl overlay that backs raster rendering.
DEFAULT_ACTIVE_PLUGIN_IDS <- c(
  "maplibre-layer-control",
  "maplibre-deckgl-viz",
  "maplibre-atmosphere-effects"
)

ensure_plugins_block <- function(project) {
  plugins <- project$plugins
  if (!is.list(plugins)) {
    plugins <- list(
      manifestUrls = empty_array(),
      activePluginIds = as_json_array(DEFAULT_ACTIVE_PLUGIN_IDS),
      mapControlPositions = empty_object(),
      settings = empty_object()
    )
  }
  if (is.null(plugins$manifestUrls)) plugins$manifestUrls <- empty_array()
  if (is.null(plugins$activePluginIds)) plugins$activePluginIds <- empty_array()
  if (is.null(plugins$mapControlPositions)) plugins$mapControlPositions <- empty_object()
  if (is.null(plugins$settings)) plugins$settings <- empty_object()
  project$plugins <- plugins
  project
}

set_plugin_state <- function(project, plugin_id, settings, position = NULL,
                             activate = TRUE) {
  project <- ensure_plugins_block(project)
  if (isTRUE(activate)) {
    active <- unlist(project$plugins$activePluginIds, use.names = FALSE)
    if (!plugin_id %in% active) {
      project$plugins$activePluginIds <- as_json_array(c(active, plugin_id))
    }
  }
  if (!is.null(position)) {
    project$plugins$mapControlPositions[[plugin_id]] <- position
  }
  project$plugins$settings[[plugin_id]] <- settings
  project
}

swipe_state <- function(left_layers, right_layers, orientation = "vertical",
                        position = 50) {
  list(
    orientation = orientation,
    position = position,
    collapsed = FALSE,
    active = TRUE,
    leftLayers = as_json_array(left_layers),
    rightLayers = as_json_array(right_layers),
    isDragging = FALSE
  )
}

legend_gui_entry <- function(title, items, position) {
  list(title = title, items = items, legendPosition = position)
}

# The Legend control renders one on-map legend per item in its `legends` array,
# so each call appends rather than replaces, and the top-level fields mirror the
# latest entry for the editing form.
legend_gui_state <- function(entry, existing = NULL) {
  prior <- if (is.list(existing)) existing$legends else NULL
  legends <- c(if (is.null(prior)) list() else prior, list(entry))
  c(
    entry,
    list(
      visible = TRUE,
      collapsed = FALSE,
      hasLegend = TRUE,
      selectedLegendIndex = length(legends) - 1L,
      legends = legends
    )
  )
}

colorbar_gui_entry <- function(mode, colormap, custom_colors, vmin, vmax, label,
                               units, orientation, position) {
  list(
    mode = mode,
    colormap = colormap,
    customColors = custom_colors,
    vmin = vmin,
    vmax = vmax,
    label = label,
    units = units,
    orientation = orientation,
    colorbarPosition = position
  )
}

colorbar_gui_state <- function(entry, existing = NULL) {
  prior <- if (is.list(existing)) existing$colorbars else NULL
  colorbars <- c(if (is.null(prior)) list() else prior, list(entry))
  c(
    entry,
    list(
      visible = TRUE,
      collapsed = FALSE,
      hasColorbar = TRUE,
      selectedColorbarIndex = length(colorbars) - 1L,
      colorbars = colorbars
    )
  )
}

# The Components plugin (legend / colorbar / html) stores all its features under
# a single settings blob keyed by feature name, so a new legend must be merged in
# without dropping an existing colorbar and vice versa.
merge_components_state <- function(project, key, build_state) {
  project <- ensure_plugins_block(project)
  current <- project$plugins$settings[[COMPONENTS_PLUGIN_ID]]
  components <- if (is.list(current)) current else empty_object()
  components[[key]] <- build_state(components[[key]])
  # The legend and colorbar restore from their settings blob alone, so the
  # plugin is configured but not activated (activating it would also mount the
  # full Components toolbar).
  set_plugin_state(project, COMPONENTS_PLUGIN_ID, components, activate = FALSE)
}
