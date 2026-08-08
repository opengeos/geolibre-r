## R CMD check results

0 errors | 0 warnings | 1 note

The note is the standard note for a first submission:

```text
New submission
```

Tested on:

- local CachyOS Linux, R 4.6.1
- GitHub Actions: Ubuntu (R-devel, R-release, R-oldrel-1)
- GitHub Actions: macOS (R-release)
- GitHub Actions: Windows (R-release)

## New submission

This is the first submission of `geolibre`.

The widget loads the GeoLibre application from `https://web.geolibre.app/` by
default when displayed. Installation, examples, tests, and R CMD check do not
contact that service. Users can configure a self-hosted deployment with the
`app_url` argument or the `geolibre.app_url` option.
