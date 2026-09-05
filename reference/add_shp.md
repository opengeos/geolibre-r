# Add a Shapefile layer

Add a Shapefile layer

## Usage

``` r
add_shp(map, data, name = "Shapefile", ...)
```

## Arguments

- map:

  A GeoLibre widget.

- data:

  A zipped Shapefile URL, or a local `.shp` path read with `sf`.

- name:

  Layer name.

- ...:

  Additional style overrides given as named arguments, merged into
  `style`. `add_geojson(map, data, fillColor = "red")` and
  `add_geojson(map, data, style = list(fillColor = "red"))` are
  equivalent.

## Value

The modified widget.

## Examples

``` r
geolibre() |> add_shp("https://example.com/data.zip")

{"x":{"project":{"version":"0.2.0","name":"Untitled Project","mapView":{"center":[-100,40],"zoom":2,"bearing":0,"pitch":0},"basemapStyleUrl":"https://tiles.openfreemap.org/styles/liberty","basemapVisible":true,"basemapOpacity":1,"layers":[{"id":"93436077-7230-466a-86ab-483b798f9b6d","name":"Shapefile","type":"geojson","visible":true,"opacity":1,"style":{"minZoom":0,"maxZoom":24,"fillColor":"#3b82f6","strokeColor":"#1e40af","strokeWidth":2,"fillOpacity":0.6,"circleRadius":6,"textColor":"#111827","textHaloColor":"#ffffff","textHaloWidth":2,"textSize":16,"extrusionEnabled":false,"extrusionColor":"#3b82f6","extrusionOpacity":0.8,"extrusionHeightProperty":"height","extrusionHeightScale":1,"extrusionBase":0,"extrusionAdvancedStyleEnabled":false,"extrusionColorExpression":"","extrusionHeightExpression":"","vectorStyleMode":"single","vectorStyleProperty":"","vectorStyleClassCount":5,"vectorStyleColorRamp":"viridis","vectorStyleClassificationScheme":"equal-interval","vectorStyleStops":[{"value":0,"color":"#dbeafe"},{"value":1,"color":"#2563eb"}],"vectorStyleExpression":"","pointRenderer":"single","heatmapRadius":30,"heatmapIntensity":1,"clusterRadius":50,"clusterMaxZoom":14,"rasterBrightnessMin":0,"rasterBrightnessMax":1,"rasterSaturation":0,"rasterContrast":0,"rasterHueRotate":0},"metadata":{"sourceKind":"maplibre-gl-vector","externalNativeLayer":true,"controlOwnsPaint":true,"identifiable":false,"nativeLayerIds":[],"sourceIds":["93436077-7230-466a-86ab-483b798f9b6d-source"],"vectorSource":"url","vectorState":{"renderMode":"geojson","format":"shp"}},"source":{"type":"geojson","url":"https://example.com/data.zip"},"sourcePath":"https://example.com/data.zip"}],"styles":{},"preferences":{"map":{"restrictBounds":false,"bounds":[-180,-85,180,85],"minZoom":0,"maxZoom":24,"maxPitch":85,"renderWorldCopies":true},"environmentVariables":[]},"metadata":{}},"appUrl":"https://web.geolibre.app/","layout":"embed","theme":"light","panels":"expanded"},"evals":[],"jsHooks":[]}
```
