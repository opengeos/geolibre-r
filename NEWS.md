# geolibre 0.2.0

First CRAN release. This release brings the R API to parity with the GeoLibre
Python API. The package now covers every layer type the application reads, layer
management, data-driven symbology, on-map controls, standalone HTML export, and
a Shiny proxy that drives the live map.

## New layer types

- Add `add_cog()` and keep `add_raster()` as its generically named alias.
- Add XYZ raster tiles with `add_tile_layer()`.
- Add OGC services with `add_wms()`, `add_wmts()`, and `add_wfs()`.
- Add `add_vector()` for any format the in-browser vector control streams, with
  `add_geoparquet()`, `add_flatgeobuf()`, `add_shp()`, `add_kml()`, and
  `add_gpkg()` wrappers. Local files are read with `sf` and inlined instead.
- Add `add_vector_tiles()`, `add_pmtiles()`, `add_3d_tiles()`, and `add_video()`.
- Add points from coordinates, matrices, data frames, or CSV with
  `add_marker()`, `add_markers()`, `add_circle_markers()`,
  `add_marker_cluster()`, `add_heatmap()`, `add_xy_data()`, and `add_csv()`.
- `add_xy_data()` now builds ordinary data-frame point features in one pass,
  substantially reducing construction time for large tables.
- Add `add_geojson()` support for HTTP(S) URLs and `sfc`/`sfg` objects, and
  `add_data()` for column-driven symbology in one call.

## Symbology and layer management

- Add `add_choropleth()` and `classify_layer()`, which compute the same
  graduated `vectorStyleStops` the application's Style panel produces, using
  equal-interval or quantile classification.
- Add the color ramp catalog: `color_ramp_names()`, `get_color_ramp()`, and
  `interpolate_ramp_colors()`.
- Add `get_layers()`, `get_layer()`, `layer_names()`, and `find_layer_index()`
  for inspection, and `layer_properties()` and `column_values()` for reading
  feature attributes back.
- Add `set_layer_visibility()`, `show_layer()`, `hide_layer()`,
  `set_layer_opacity()`, `set_layer_style()`, `rename_layer()`, `move_layer()`,
  `duplicate_layer()`, `remove_layer()`, and `clear_layers()`. Each accepts a
  layer id or a layer name.
- Every `add_*()` function now accepts style overrides as named arguments as
  well as through `style`, so `add_geojson(map, data, fillColor = "red")` works.
- Layers now carry the application's full default style, so a project
  round-trips without the application filling in gaps differently.

## Map controls and the camera

- Add `add_legend()` from a named vector, parallel label and color vectors, or a
  built-in preset; `builtin_legend_names()` lists the presets.
- Add `add_colorbar()` and `add_colormap()` for continuous rasters, from a named
  ramp or a custom gradient.
- Add `split_map()` for before-and-after swipe comparisons.
- Add `set_center()`, `set_zoom()`, `set_bearing()`, `set_pitch()`, and
  `fit_bounds()`, which frames a bounding box and handles boxes that cross the
  antimeridian.
- Add `set_basemap()` and `add_basemap()`, plus the `basemaps()` catalog.
  `geolibre()` also takes `center`, `zoom`, `basemap`, and `name` directly.
- Add `layout` and `theme` arguments to `geolibre()`. `layout = "full"` shows the
  complete desktop interface. `map_only` is superseded by `layout = "maponly"`
  and still works.

## Projects, export, and credentials

- Add `to_html()`, which writes a standalone page that needs no running R
  session.
- Add `get_project()` and `describe_project()`, and `set_project_name()`.
- Add `redact_credentials()`, `redact_layer()`, and `redact_url()`.
  `save_project()` now strips credentials by default; pass
  `keep_credentials = TRUE` for a trusted local file.

## Shiny

- Add a command bridge so a proxy can drive the live map: `geolibre_fly_to()`,
  `geolibre_fit_bounds()`, `geolibre_zoom_to_layer()`, `geolibre_get_view()`,
  `geolibre_identify()`, `geolibre_layer_features()`,
  `geolibre_selected_features()`, `geolibre_drawn_features()`,
  `geolibre_list_algorithms()`, `geolibre_run_algorithm()`,
  `geolibre_to_image()`, and the general `geolibre_command()`.
- Replies arrive on `input$<outputId>_result` and user interaction on
  `input$<outputId>_event`, alongside the existing `_project` and `_error`
  inputs.

## Bug fixes

- `add_marker()` and named `add_markers()` entries now reject invalid coordinates
  and properties instead of serializing malformed GeoJSON.
- `set_view(bbox = )` wrote an unknown `bounds` field that the application
  ignored, so the requested extent was silently dropped. It now resolves the box
  to the `center`, `zoom`, and `bbox` the application reads.
- The default camera now matches the application's own, `c(-100, 40)` at zoom 2,
  rather than `c(0, 20)`.

# geolibre 0.1.0

Initial release, on GitHub only.

- Add a responsive `htmlwidgets` interface to GeoLibre for RStudio, Quarto,
  R Markdown, and Shiny.
- Add GeoJSON and `sf` vector layers and remote COG/GeoTIFF raster layers.
- Add camera controls and `.geolibre.json` project import and export.
- Add Shiny output, render, proxy, and live project-state bindings.
- Support hosted and self-hosted GeoLibre deployments.
