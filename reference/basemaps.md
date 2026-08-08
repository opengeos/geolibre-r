# Named GeoLibre basemaps

Lists the vector basemap styles that
[`set_basemap()`](https://r.geolibre.app/reference/set_basemap.md) and
[`geolibre()`](https://r.geolibre.app/reference/geolibre.md) accept by
name. Raster tile basemaps such as OpenStreetMap are added as layers
with
[`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md)
instead.

## Usage

``` r
basemaps()
```

## Value

A named character vector mapping basemap name to MapLibre style URL.

## Examples

``` r
basemaps()
#>                                         liberty 
#>  "https://tiles.openfreemap.org/styles/liberty" 
#>                                          bright 
#>   "https://tiles.openfreemap.org/styles/bright" 
#>                                        positron 
#> "https://tiles.openfreemap.org/styles/positron" 
#>                                            dark 
#>     "https://tiles.openfreemap.org/styles/dark" 
#>                                           fiord 
#>    "https://tiles.openfreemap.org/styles/fiord" 
names(basemaps())
#> [1] "liberty"  "bright"   "positron" "dark"     "fiord"   
```
