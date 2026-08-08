# Export a map as a standalone HTML page

The page embeds the GeoLibre application in an `iframe` and injects the
project into it over the same `postMessage` bridge the widget uses, so
it renders the map as configured. Unlike the widget it needs no running
R session; by default it loads the hosted application over the network
so the file stays portable.

## Usage

``` r
to_html(
  map,
  path = NULL,
  title = "GeoLibre Map",
  width = "100%",
  height = "800px",
  app_url = getOption("geolibre.app_url", "https://web.geolibre.app/")
)
```

## Arguments

- map:

  A GeoLibre widget or project list.

- path:

  Optional output path. When supplied the page is written there and
  `path` is returned invisibly; otherwise the HTML is returned as a
  string.

- title:

  The exported page's `title`.

- width:

  CSS width of the embedded map, for example `"100%"` or `"800px"`.

- height:

  CSS height of the embedded map.

- app_url:

  Base URL of the GeoLibre application to embed. Defaults to the hosted
  viewer so the export stays portable; pass a self-hosted deployment URL
  to pin a specific version.

## Value

The HTML string, or `path` invisibly when `path` is supplied.

## Details

Credentials are stripped from the inlined project on the way out, as
[`save_project()`](https://r.geolibre.app/reference/save_project.md)
does.

## See also

[`save_project()`](https://r.geolibre.app/reference/save_project.md) to
write the project itself

## Examples

``` r
map <- geolibre() |> add_marker(-77.0369, 38.9072, name = "DC")
html <- to_html(map, title = "Washington, DC")
substr(html, 1, 15)
#> [1] "<!doctype html>"

path <- tempfile(fileext = ".html")
to_html(map, path)
```
