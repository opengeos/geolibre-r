# Strip credentials from one layer

Strip credentials from one layer

## Usage

``` r
redact_layer(layer)
```

## Arguments

- layer:

  A layer list, as returned inside a project's `layers`.

## Value

The layer with its credential-bearing configuration removed.

## Examples

``` r
map <- geolibre() |>
  add_3d_tiles(
    "https://example.com/tileset.json",
    request_headers = list(Authorization = "Bearer secret")
  )
layer <- redact_layer(map$x$project$layers[[1]])
is.null(layer$source$requestHeaders)
#> [1] TRUE
```
