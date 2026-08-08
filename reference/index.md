# Package index

## Create a map

- [`geolibre()`](https://r.geolibre.app/reference/geolibre.md) : Create
  a GeoLibre widget

## Vector layers

Vector data from GeoJSON, `sf`, or any format the browser can stream.

- [`add_geojson()`](https://r.geolibre.app/reference/add_geojson.md) :
  Add GeoJSON to a GeoLibre map

- [`add_sf()`](https://r.geolibre.app/reference/add_sf.md) :

  Add an `sf` object to a GeoLibre map

- [`add_data()`](https://r.geolibre.app/reference/add_data.md) : Add
  data, optionally symbolized by a column

- [`add_choropleth()`](https://r.geolibre.app/reference/add_choropleth.md)
  : Add a data-driven choropleth layer

- [`add_vector()`](https://r.geolibre.app/reference/add_vector.md) : Add
  a vector dataset from a URL or local file

- [`add_geoparquet()`](https://r.geolibre.app/reference/add_geoparquet.md)
  : Add a GeoParquet layer

- [`add_flatgeobuf()`](https://r.geolibre.app/reference/add_flatgeobuf.md)
  : Add a FlatGeobuf layer

- [`add_shp()`](https://r.geolibre.app/reference/add_shp.md) : Add a
  Shapefile layer

- [`add_kml()`](https://r.geolibre.app/reference/add_kml.md) : Add a KML
  or KMZ layer

- [`add_gpkg()`](https://r.geolibre.app/reference/add_gpkg.md) : Add a
  GeoPackage layer

## Points and markers

- [`add_marker()`](https://r.geolibre.app/reference/add_marker.md) : Add
  a single point marker
- [`add_markers()`](https://r.geolibre.app/reference/add_markers.md) :
  Add point markers
- [`add_circle_markers()`](https://r.geolibre.app/reference/add_circle_markers.md)
  : Add circle markers
- [`add_marker_cluster()`](https://r.geolibre.app/reference/add_marker_cluster.md)
  : Add clustered point markers
- [`add_heatmap()`](https://r.geolibre.app/reference/add_heatmap.md) :
  Add a point density heatmap
- [`add_xy_data()`](https://r.geolibre.app/reference/add_xy_data.md) :
  Add points from tabular longitude and latitude columns
- [`add_csv()`](https://r.geolibre.app/reference/add_csv.md) : Add a CSV
  of point coordinates

## Rasters, tiles, and services

- [`add_raster()`](https://r.geolibre.app/reference/add_raster.md) : Add
  a remote raster to a GeoLibre map
- [`add_cog()`](https://r.geolibre.app/reference/add_cog.md) : Add a
  Cloud Optimized GeoTIFF layer
- [`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md)
  : Add an XYZ raster tile layer
- [`add_wms()`](https://r.geolibre.app/reference/add_wms.md) : Add a WMS
  layer
- [`add_wmts()`](https://r.geolibre.app/reference/add_wmts.md) : Add a
  WMTS layer
- [`add_wfs()`](https://r.geolibre.app/reference/add_wfs.md) : Add a WFS
  layer
- [`add_vector_tiles()`](https://r.geolibre.app/reference/add_vector_tiles.md)
  : Add a vector tile layer from a TileJSON endpoint
- [`add_pmtiles()`](https://r.geolibre.app/reference/add_pmtiles.md) :
  Add a PMTiles layer
- [`add_3d_tiles()`](https://r.geolibre.app/reference/add_3d_tiles.md) :
  Add a 3D Tiles layer
- [`add_video()`](https://r.geolibre.app/reference/add_video.md) : Add a
  georeferenced video layer

## Work with layers

Every function here addresses a layer by its id or its name.

- [`get_layers()`](https://r.geolibre.app/reference/get_layers.md) :
  Summarize a project's layers
- [`get_layer()`](https://r.geolibre.app/reference/get_layer.md) : Read
  one layer's full definition
- [`layer_names()`](https://r.geolibre.app/reference/layer_names.md) :
  Layer names in draw order
- [`find_layer_index()`](https://r.geolibre.app/reference/find_layer_index.md)
  : Position of a layer in the draw order
- [`set_layer_visibility()`](https://r.geolibre.app/reference/set_layer_visibility.md)
  [`show_layer()`](https://r.geolibre.app/reference/set_layer_visibility.md)
  [`hide_layer()`](https://r.geolibre.app/reference/set_layer_visibility.md)
  : Show or hide a layer
- [`set_layer_opacity()`](https://r.geolibre.app/reference/set_layer_opacity.md)
  : Set a layer's opacity
- [`set_layer_style()`](https://r.geolibre.app/reference/set_layer_style.md)
  : Restyle a layer
- [`classify_layer()`](https://r.geolibre.app/reference/classify_layer.md)
  : Symbolize an existing layer as a choropleth
- [`rename_layer()`](https://r.geolibre.app/reference/rename_layer.md) :
  Rename a layer
- [`move_layer()`](https://r.geolibre.app/reference/move_layer.md) :
  Move a layer in the draw order
- [`duplicate_layer()`](https://r.geolibre.app/reference/duplicate_layer.md)
  : Duplicate a layer
- [`remove_layer()`](https://r.geolibre.app/reference/remove_layer.md) :
  Remove a layer
- [`clear_layers()`](https://r.geolibre.app/reference/clear_layers.md) :
  Remove every layer
- [`layer_properties()`](https://r.geolibre.app/reference/layer_properties.md)
  : Sample a layer's feature properties
- [`column_values()`](https://r.geolibre.app/reference/column_values.md)
  : Read one feature property across a layer

## Camera and basemap

- [`set_view()`](https://r.geolibre.app/reference/set_view.md) : Set the
  GeoLibre camera
- [`set_center()`](https://r.geolibre.app/reference/set_center.md) :
  Center the map
- [`set_zoom()`](https://r.geolibre.app/reference/set_zoom.md) : Set the
  map zoom
- [`set_bearing()`](https://r.geolibre.app/reference/set_bearing.md) :
  Set the camera bearing
- [`set_pitch()`](https://r.geolibre.app/reference/set_pitch.md) : Set
  the camera pitch
- [`fit_bounds()`](https://r.geolibre.app/reference/fit_bounds.md) :
  Frame a bounding box
- [`set_basemap()`](https://r.geolibre.app/reference/set_basemap.md)
  [`add_basemap()`](https://r.geolibre.app/reference/set_basemap.md) :
  Set the background basemap
- [`set_project_name()`](https://r.geolibre.app/reference/set_project_name.md)
  : Set the project name

## Map controls

- [`add_legend()`](https://r.geolibre.app/reference/add_legend.md) : Add
  a legend to the map
- [`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md) :
  Add a colorbar to the map
- [`add_colormap()`](https://r.geolibre.app/reference/add_colormap.md) :
  Add a colorbar from a named color ramp
- [`split_map()`](https://r.geolibre.app/reference/split_map.md) : Add a
  split-map comparison slider

## Catalogs

The basemaps, color ramps, and legend presets the application ships.

- [`basemaps()`](https://r.geolibre.app/reference/basemaps.md) : Named
  GeoLibre basemaps
- [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md)
  : Available color ramp names
- [`get_color_ramp()`](https://r.geolibre.app/reference/get_color_ramp.md)
  : Anchor colors of a color ramp
- [`interpolate_ramp_colors()`](https://r.geolibre.app/reference/interpolate_ramp_colors.md)
  : Sample a color ramp into evenly spaced colors
- [`builtin_legend_names()`](https://r.geolibre.app/reference/builtin_legend_names.md)
  : Built-in legend preset names

## Projects and export

- [`load_project()`](https://r.geolibre.app/reference/load_project.md) :
  Read a GeoLibre project
- [`save_project()`](https://r.geolibre.app/reference/save_project.md) :
  Save a GeoLibre project
- [`get_project()`](https://r.geolibre.app/reference/get_project.md) :
  Read a project out of a widget
- [`describe_project()`](https://r.geolibre.app/reference/describe_project.md)
  : Summarize a GeoLibre project
- [`to_html()`](https://r.geolibre.app/reference/to_html.md) : Export a
  map as a standalone HTML page
- [`redact_credentials()`](https://r.geolibre.app/reference/redact_credentials.md)
  : Strip credentials from a whole project
- [`redact_layer()`](https://r.geolibre.app/reference/redact_layer.md) :
  Strip credentials from one layer
- [`redact_url()`](https://r.geolibre.app/reference/redact_url.md) :
  Strip credentials from a URL

## Shiny

Render a widget, then drive the live map through a proxy.

- [`geolibreOutput()`](https://r.geolibre.app/reference/geolibreOutput.md)
  [`renderGeolibre()`](https://r.geolibre.app/reference/geolibreOutput.md)
  : Shiny bindings for GeoLibre
- [`geolibre_proxy()`](https://r.geolibre.app/reference/geolibre_proxy.md)
  : Create a GeoLibre Shiny proxy
- [`update_geolibre()`](https://r.geolibre.app/reference/update_geolibre.md)
  : Replace the project displayed by a GeoLibre Shiny widget
- [`geolibre_command()`](https://r.geolibre.app/reference/geolibre_command.md)
  : Send a command to a live GeoLibre map
- [`geolibre_fly_to()`](https://r.geolibre.app/reference/geolibre_fly_to.md)
  : Animate the camera of a live GeoLibre map
- [`geolibre_fit_bounds()`](https://r.geolibre.app/reference/geolibre_fit_bounds.md)
  : Fit a live GeoLibre map to a bounding box
- [`geolibre_zoom_to_layer()`](https://r.geolibre.app/reference/geolibre_zoom_to_layer.md)
  : Zoom a live GeoLibre map to a layer's extent
- [`geolibre_get_view()`](https://r.geolibre.app/reference/geolibre_get_view.md)
  : Read the camera of a live GeoLibre map
- [`geolibre_identify()`](https://r.geolibre.app/reference/geolibre_identify.md)
  : Identify features at a point on a live GeoLibre map
- [`geolibre_layer_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md)
  [`geolibre_selected_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md)
  [`geolibre_drawn_features()`](https://r.geolibre.app/reference/geolibre_layer_features.md)
  : Read features from a live GeoLibre map
- [`geolibre_run_algorithm()`](https://r.geolibre.app/reference/geolibre_run_algorithm.md)
  [`geolibre_list_algorithms()`](https://r.geolibre.app/reference/geolibre_run_algorithm.md)
  : Run a processing algorithm on a live GeoLibre map
- [`geolibre_to_image()`](https://r.geolibre.app/reference/geolibre_to_image.md)
  : Capture a live GeoLibre map as a PNG
