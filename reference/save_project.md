# Save a GeoLibre project

Save a GeoLibre project

## Usage

``` r
save_project(map, path, keep_credentials = FALSE)
```

## Arguments

- map:

  A GeoLibre widget or project list.

- path:

  Output path, conventionally ending in `.geolibre.json`.

- keep_credentials:

  Keep credential-bearing configuration such as layer request headers
  and signed URLs. Defaults to `FALSE`, so a saved project is safe to
  commit or share. See
  [`redact_credentials()`](https://r.geolibre.app/reference/redact_credentials.md).

## Value

`path`, invisibly.

## See also

[`load_project()`](https://r.geolibre.app/reference/load_project.md),
[`redact_credentials()`](https://r.geolibre.app/reference/redact_credentials.md)

## Examples

``` r
path <- tempfile(fileext = ".geolibre.json")
save_project(geolibre(), path)
project <- load_project(path)
stopifnot(project$name == "Untitled Project")
```
