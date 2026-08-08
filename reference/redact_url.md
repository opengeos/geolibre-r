# Strip credentials from a URL

Removes any `user:password@` prefix and any query parameter whose name
marks it as a credential, such as `api_key`, `access_token`, or an Azure
shared-access signature. The rest of the URL is left byte-for-byte
intact.

## Usage

``` r
redact_url(url)
```

## Arguments

- url:

  A URL string.

## Value

The URL with its credentials removed.

## Examples

``` r
redact_url("https://tiles.example.com/style.json?api_key=secret&lang=en")
#> [1] "https://tiles.example.com/style.json?lang=en"
redact_url("https://user:pw@example.com/data.tif")
#> [1] "https://example.com/data.tif"
```
