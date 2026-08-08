# Add a KML or KMZ layer

Add a KML or KMZ layer

## Usage

``` r
add_kml(map, data, name = "KML", ...)
```

## Arguments

- map:

  A GeoLibre widget.

- data:

  A dataset URL, a local file path, or an `sf` object.

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
geolibre() |> add_kml("https://example.com/places.kml")

{"x":{"project":{"version":"0.2.0","name":"Untitled Project","mapView":{"center":[-100,40],"zoom":2,"bearing":0,"pitch":0},"basemapStyleUrl":"https://tiles.openfreemap.org/styles/liberty","basemapVisible":true,"basemapOpacity":1,"layers":[{"id":"2a7b9c8a-f869-4373-ba62-bce43f5714ef","name":"KML","type":"geojson","visible":true,"opacity":1,"style":{"minZoom":0,"maxZoom":24,"fillColor":"#3b82f6","strokeColor":"#1e40af","strokeWidth":2,"fillOpacity":0.6,"circleRadius":6,"textColor":"#111827","textHaloColor":"#ffffff","textHaloWidth":2,"textSize":16,"extrusionEnabled":false,"extrusionColor":"#3b82f6","extrusionOpacity":0.8,"extrusionHeightProperty":"height","extrusionHeightScale":1,"extrusionBase":0,"extrusionAdvancedStyleEnabled":false,"extrusionColorExpression":"","extrusionHeightExpression":"","vectorStyleMode":"single","vectorStyleProperty":"","vectorStyleClassCount":5,"vectorStyleColorRamp":"viridis","vectorStyleClassificationScheme":"equal-interval","vectorStyleStops":[{"value":0,"color":"#dbeafe"},{"value":1,"color":"#2563eb"}],"vectorStyleExpression":"","pointRenderer":"single","heatmapRadius":30,"heatmapIntensity":1,"clusterRadius":50,"clusterMaxZoom":14,"rasterBrightnessMin":0,"rasterBrightnessMax":1,"rasterSaturation":0,"rasterContrast":0,"rasterHueRotate":0},"metadata":{"sourceKind":"maplibre-gl-vector","externalNativeLayer":true,"controlOwnsPaint":true,"identifiable":false,"nativeLayerIds":[],"sourceIds":["2a7b9c8a-f869-4373-ba62-bce43f5714ef-source"],"vectorSource":"url","vectorState":{"renderMode":"geojson","format":"kml"}},"source":{"type":"geojson","url":"https://example.com/places.kml"},"sourcePath":"https://example.com/places.kml"}],"styles":{},"preferences":{"map":{"restrictBounds":false,"bounds":[-180,-85,180,85],"minZoom":0,"maxZoom":24,"maxPitch":85,"renderWorldCopies":true},"environmentVariables":[]},"metadata":{}},"appUrl":"https://web.geolibre.app/","layout":"embed","theme":"light","panels":"expanded"},"evals":[],"jsHooks":[]}
```
