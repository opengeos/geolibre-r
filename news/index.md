# Changelog

## geolibre 0.2.0

This release brings the R API to parity with the GeoLibre Python API.
The package now covers every layer type the application reads, layer
management, data-driven symbology, on-map controls, standalone HTML
export, and a Shiny proxy that drives the live map.

### New layer types

- Add [`add_cog()`](https://r.geolibre.app/reference/add_cog.md) and
  keep [`add_raster()`](https://r.geolibre.app/reference/add_raster.md)
  as its generically named alias.
- Add XYZ raster tiles with
  [`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md).
- Add OGC services with
  [`add_wms()`](https://r.geolibre.app/reference/add_wms.md),
  [`add_wmts()`](https://r.geolibre.app/reference/add_wmts.md), and
  [`add_wfs()`](https://r.geolibre.app/reference/add_wfs.md).
- Add [`add_vector()`](https://r.geolibre.app/reference/add_vector.md)
  for any format the in-browser vector control streams, with
  [`add_geoparquet()`](https://r.geolibre.app/reference/add_geoparquet.md),
  [`add_flatgeobuf()`](https://r.geolibre.app/reference/add_flatgeobuf.md),
  [`add_shp()`](https://r.geolibre.app/reference/add_shp.md),
  [`add_kml()`](https://r.geolibre.app/reference/add_kml.md), and
  [`add_gpkg()`](https://r.geolibre.app/reference/add_gpkg.md) wrappers.
  Local files are read with `sf` and inlined instead.
- Add
  [`add_vector_tiles()`](https://r.geolibre.app/reference/add_vector_tiles.md),
  [`add_pmtiles()`](https://r.geolibre.app/reference/add_pmtiles.md),
  [`add_3d_tiles()`](https://r.geolibre.app/reference/add_3d_tiles.md),
  and [`add_video()`](https://r.geolibre.app/reference/add_video.md).
- Add points from coordinates, matrices, data frames, or CSV with
  [`add_marker()`](https://r.geolibre.app/reference/add_marker.md),
  [`add_markers()`](https://r.geolibre.app/reference/add_markers.md),
  [`add_circle_markers()`](https://r.geolibre.app/reference/add_circle_markers.md),
  [`add_marker_cluster()`](https://r.geolibre.app/reference/add_marker_cluster.md),
  [`add_heatmap()`](https://r.geolibre.app/reference/add_heatmap.md),
  [`add_xy_data()`](https://r.geolibre.app/reference/add_xy_data.md),
  and [`add_csv()`](https://r.geolibre.app/reference/add_csv.md).
- Add [`add_geojson()`](https://r.geolibre.app/reference/add_geojson.md)
  support for HTTP(S) URLs and `sfc`/`sfg` objects, and
  [`add_data()`](https://r.geolibre.app/reference/add_data.md) for
  column-driven symbology in one call.

### Symbology and layer management

- Add
  [`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md)
  and
  [`classify_layer()`](https://r.geolibre.app/reference/classify_layer.md),
  which compute the same graduated `vectorStyleStops` the application’s
  Style panel produces, using equal-interval or quantile classification.
- Add the color ramp catalog:
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md),
  [`get_color_ramp()`](https://r.geolibre.app/reference/get_color_ramp.md),
  and
  [`interpolate_ramp_colors()`](https://r.geolibre.app/reference/interpolate_ramp_colors.md).
- Add [`get_layers()`](https://r.geolibre.app/reference/get_layers.md),
  [`get_layer()`](https://r.geolibre.app/reference/get_layer.md),
  [`layer_names()`](https://r.geolibre.app/reference/layer_names.md),
  and
  [`find_layer_index()`](https://r.geolibre.app/reference/find_layer_index.md)
  for inspection, and
  [`layer_properties()`](https://r.geolibre.app/reference/layer_properties.md)
  and
  [`column_values()`](https://r.geolibre.app/reference/column_values.md)
  for reading feature attributes back.
- Add
  [`set_layer_visibility()`](https://r.geolibre.app/reference/set_layer_visibility.md),
  [`show_layer()`](https://r.geolibre.app/reference/set_layer_visibility.md),
  [`hide_layer()`](https://r.geolibre.app/reference/set_layer_visibility.md),
  [`set_layer_opacity()`](https://r.geolibre.app/reference/set_layer_opacity.md),
  [`set_layer_style()`](https://r.geolibre.app/reference/set_layer_style.md),
  [`rename_layer()`](https://r.geolibre.app/reference/rename_layer.md),
  [`move_layer()`](https://r.geolibre.app/reference/move_layer.md),
  [`duplicate_layer()`](https://r.geolibre.app/reference/duplicate_layer.md),
  [`remove_layer()`](https://r.geolibre.app/reference/remove_layer.md),
  and
  [`clear_layers()`](https://r.geolibre.app/reference/clear_layers.md).
  Each accepts a layer id or a layer name.
- Every `add_*()` function now accepts style overrides as named
  arguments as well as through `style`, so
  `add_geojson(map, data, fillColor = "red")` works.
- Layers now carry the application’s full default style, so a project
  round-trips without the application filling in gaps differently.

### Map controls and the camera

- Add [`add_legend()`](https://r.geolibre.app/reference/add_legend.md)
  from a named vector, parallel label and color vectors, or a built-in
  preset;
  [`builtin_legend_names()`](https://r.geolibre.app/reference/builtin_legend_names.md)
  lists the presets.
- Add
  [`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md)
  and
  [`add_colormap()`](https://r.geolibre.app/reference/add_colormap.md)
  for continuous rasters, from a named ramp or a custom gradient.
- Add [`split_map()`](https://r.geolibre.app/reference/split_map.md) for
  before-and-after swipe comparisons.
- Add [`set_center()`](https://r.geolibre.app/reference/set_center.md),
  [`set_zoom()`](https://r.geolibre.app/reference/set_zoom.md),
  [`set_bearing()`](https://r.geolibre.app/reference/set_bearing.md),
  [`set_pitch()`](https://r.geolibre.app/reference/set_pitch.md), and
  [`fit_bounds()`](https://r.geolibre.app/reference/fit_bounds.md),
  which frames a bounding box and handles boxes that cross the
  antimeridian.
- Add [`set_basemap()`](https://r.geolibre.app/reference/set_basemap.md)
  and
  [`add_basemap()`](https://r.geolibre.app/reference/set_basemap.md),
  plus the [`basemaps()`](https://r.geolibre.app/reference/basemaps.md)
  catalog. [`geolibre()`](https://r.geolibre.app/reference/geolibre.md)
  also takes `center`, `zoom`, `basemap`, and `name` directly.
- Add `layout` and `theme` arguments to
  [`geolibre()`](https://r.geolibre.app/reference/geolibre.md).
  `layout = "full"` shows the complete desktop interface. `map_only` is
  superseded by `layout = "maponly"` and still works.

### Projects, export, and credentials

- Add [`to_html()`](https://r.geolibre.app/reference/to_html.md), which
  writes a standalone page that needs no running R session.
- Add [`get_project()`](https://r.geolibre.app/reference/get_project.md)
  and
  [`describe_project()`](https://r.geolibre.app/reference/describe_project.md),
  and
  [`set_project_name()`](https://r.geolibre.app/reference/set_project_name.md).
- Add
  [`redact_credentials()`](https://r.geolibre.app/reference/redact_credentials.md),
  [`redact_layer()`](https://r.geolibre.app/reference/redact_layer.md),
  and [`redact_url()`](https://r.geolibre.app/reference/redact_url.md).
  [`save_project()`](https://r.geolibre.app/reference/save_project.md)
  now strips credentials by default; pass `keep_credentials = TRUE` for
  a trusted local file.

### Shiny

- Add a command bridge so a proxy can drive the live map:
  [`geolibre_fly_to()`](https://r.geolibre.app/reference/geolibre_fly_to.md),
  [`geolibre_fit_bounds()`](https://r.geolibre.app/reference/geolibre_fit_bounds.md),
  [`geolibre_zoom_to_layer()`](https://r.geolibre.app/reference/geolibre_zoom_to_layer.md),
  [`geolibre_get_view()`](https://r.geolibre.app/reference/geolibre_get_view.md),
  [`geolibre_identify()`](https://r.geolibre.app/reference/geolibre_identify.md),
  [`geolibre_layer_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md),
  [`geolibre_selected_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md),
  [`geolibre_drawn_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md),
  [`geolibre_list_algorithms()`](https://r.geolibre.app/reference/geolibre_run_algorithm.md),
  [`geolibre_run_algorithm()`](https://r.geolibre.app/reference/geolibre_run_algorithm.md),
  [`geolibre_to_image()`](https://r.geolibre.app/reference/geolibre_to_image.md),
  and the general
  [`geolibre_command()`](https://r.geolibre.app/reference/geolibre_command.md).
- Replies arrive on `input$<outputId>_result` and user interaction on
  `input$<outputId>_event`, alongside the existing `_project` and
  `_error` inputs.

### Bug fixes

- `set_view(bbox = )` wrote an unknown `bounds` field that the
  application ignored, so the requested extent was silently dropped. It
  now resolves the box to the `center`, `zoom`, and `bbox` the
  application reads.
- The default camera now matches the application’s own, `c(-100, 40)` at
  zoom 2, rather than `c(0, 20)`.

## geolibre 0.1.0

Initial CRAN release.

- Add a responsive `htmlwidgets` interface to GeoLibre for RStudio,
  Quarto, R Markdown, and Shiny.
- Add GeoJSON and `sf` vector layers and remote COG/GeoTIFF raster
  layers.
- Add camera controls and `.geolibre.json` project import and export.
- Add Shiny output, render, proxy, and live project-state bindings.
- Support hosted and self-hosted GeoLibre deployments.
