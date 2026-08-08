# Add a colorbar from a named color ramp

[`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md)
with `colormap` in the leading position, for parity with the Python API.

## Usage

``` r
add_colormap(map, colormap = "viridis", vmin = 0, vmax = 1, label = "", ...)
```

## Arguments

- map:

  A GeoLibre widget.

- colormap:

  A color ramp name from
  [`color_ramp_names()`](https://r.geolibre.app/reference/color_ramp_names.md).
  Ignored when `colors` is supplied.

- vmin:

  Value at the low end of the colorbar.

- vmax:

  Value at the high end of the colorbar.

- label:

  Title shown alongside the colorbar.

- ...:

  Forwarded to
  [`add_colorbar()`](https://r.geolibre.app/reference/add_colorbar.md),
  for example `units`, `orientation`, or `position`.

## Value

The modified widget.

## Examples

``` r
geolibre() |> add_colormap("plasma", vmin = 0, vmax = 100, label = "Index")

{"x":{"project":{"version":"0.2.0","name":"Untitled Project","mapView":{"center":[-100,40],"zoom":2,"bearing":0,"pitch":0},"basemapStyleUrl":"https://tiles.openfreemap.org/styles/liberty","basemapVisible":true,"basemapOpacity":1,"layers":[],"styles":{},"preferences":{"map":{"restrictBounds":false,"bounds":[-180,-85,180,85],"minZoom":0,"maxZoom":24,"maxPitch":85,"renderWorldCopies":true},"environmentVariables":[]},"metadata":{},"plugins":{"manifestUrls":[],"activePluginIds":["maplibre-layer-control","maplibre-deckgl-viz","maplibre-atmosphere-effects"],"mapControlPositions":{},"settings":{"maplibre-gl-components":{"colorbar":{"mode":"named","colormap":"plasma","customColors":"","vmin":0,"vmax":100,"label":"Index","units":"","orientation":"vertical","colorbarPosition":"bottom-right","visible":true,"collapsed":false,"hasColorbar":true,"selectedColorbarIndex":0,"colorbars":[{"mode":"named","colormap":"plasma","customColors":"","vmin":0,"vmax":100,"label":"Index","units":"","orientation":"vertical","colorbarPosition":"bottom-right"}]}}}}},"appUrl":"https://web.geolibre.app/","layout":"embed","theme":"light","panels":"expanded"},"evals":[],"jsHooks":[]}
```
