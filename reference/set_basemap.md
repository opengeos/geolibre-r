# Set the background basemap

Set the background basemap

## Usage

``` r
set_basemap(map, basemap)

add_basemap(map, basemap)
```

## Arguments

- map:

  A GeoLibre widget.

- basemap:

  A basemap name from
  [`basemaps()`](https://r.geolibre.app/reference/basemaps.md) or a
  MapLibre style JSON URL.

## Value

The modified widget.

## See also

[`basemaps()`](https://r.geolibre.app/reference/basemaps.md),
[`add_tile_layer()`](https://r.geolibre.app/reference/add_tile_layer.md)
for raster basemaps such as OpenStreetMap.

## Examples

``` r
map <- geolibre() |> set_basemap("dark")
map$x$project$basemapStyleUrl
#> [1] "https://tiles.openfreemap.org/styles/dark"
```
