# Standalone HTML export: a self-contained page that embeds the GeoLibre
# application in an iframe and injects the project over the same postMessage
# bridge the widget uses.

# A CSS length or percentage such as "100%", "800px", or "calc(100% - 2rem)". The
# allowed set deliberately excludes the structural CSS characters "{};:" so a
# width or height cannot close the style rule and inject CSS of its own.
CSS_DIMENSION_PATTERN <- "^[[:alnum:]%._+[:space:]()-]+$"

html_escape <- function(value) {
  value <- as.character(value)
  value <- gsub("&", "&amp;", value, fixed = TRUE)
  value <- gsub("<", "&lt;", value, fixed = TRUE)
  value <- gsub(">", "&gt;", value, fixed = TRUE)
  value <- gsub("\"", "&quot;", value, fixed = TRUE)
  gsub("'", "&#39;", value, fixed = TRUE)
}

#' Export a map as a standalone HTML page
#'
#' The page embeds the GeoLibre application in an `iframe` and injects the
#' project into it over the same `postMessage` bridge the widget uses, so it
#' renders the map as configured. Unlike the widget it needs no running R
#' session; by default it loads the hosted application over the network so the
#' file stays portable.
#'
#' Credentials are stripped from the inlined project on the way out, as
#' [save_project()] does.
#'
#' @param map A GeoLibre widget or project list.
#' @param path Optional output path. When supplied the page is written there and
#'   `path` is returned invisibly; otherwise the HTML is returned as a string.
#' @param title The exported page's `title`.
#' @param width CSS width of the embedded map, for example `"100%"` or `"800px"`.
#' @param height CSS height of the embedded map.
#' @param app_url Base URL of the GeoLibre application to embed. Defaults to the
#'   hosted viewer so the export stays portable; pass a self-hosted deployment
#'   URL to pin a specific version.
#' @return The HTML string, or `path` invisibly when `path` is supplied.
#' @seealso [save_project()] to write the project itself
#' @examples
#' map <- geolibre() |> add_marker(-77.0369, 38.9072, name = "DC")
#' html <- to_html(map, title = "Washington, DC")
#' substr(html, 1, 15)
#'
#' path <- tempfile(fileext = ".html")
#' to_html(map, path)
#' @export
to_html <- function(map, path = NULL, title = "GeoLibre Map", width = "100%",
                    height = "800px",
                    app_url = getOption("geolibre.app_url", "https://web.geolibre.app/")) {
  check_string(title, "title")
  check_http_url(app_url, "app_url")
  if (!is_scalar_string(width) || !grepl(CSS_DIMENSION_PATTERN, width)) {
    stop_geolibre("`width` must be a plain CSS dimension such as \"100%\" or \"800px\".")
  }
  if (!is_scalar_string(height) || !grepl(CSS_DIMENSION_PATTERN, height)) {
    stop_geolibre("`height` must be a plain CSS dimension such as \"600px\".")
  }
  project <- redact_credentials(as_project_list(map))

  # The project is posted into the frame, so the application URL decides where it
  # lands. Post to that exact origin rather than "*".
  origin <- sub("^(https?://[^/?#]+).*$", "\\1", app_url)
  # Insert `embed=1` before any fragment: a "#..." fragment would otherwise
  # swallow a trailing "?embed=1", so the application never sees the flag.
  hash_at <- regexpr("#", app_url, fixed = TRUE)
  base <- if (hash_at > 0) substr(app_url, 1, hash_at - 1) else app_url
  fragment <- if (hash_at > 0) substr(app_url, hash_at, nchar(app_url)) else ""
  separator <- if (grepl("?", base, fixed = TRUE)) "&" else "?"
  iframe_src <- paste0(base, separator, "embed=1", fragment)

  # Inline the project inside a JSON script block and escape "<" so a property
  # value can never break out of the script element. "<" is valid JSON that
  # JSON.parse restores to "<".
  project_json <- gsub(
    "<", "\\u003c",
    as.character(jsonlite::toJSON(
      project,
      auto_unbox = TRUE, null = "null", na = "null", digits = NA
    )),
    fixed = TRUE
  )

  html <- paste0(
    '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8" />\n',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0" />\n',
    "<title>", html_escape(title), "</title>\n<style>\n",
    "  html, body { margin: 0; padding: 0; height: 100%; }\n",
    "  #geolibre-frame { border: 0; display: block; width: ",
    html_escape(width), "; height: ", html_escape(height), "; }\n",
    "</style>\n</head>\n<body>\n",
    '<iframe id="geolibre-frame" src="', html_escape(iframe_src),
    '" allow="fullscreen" allowfullscreen></iframe>\n',
    '<script type="application/json" id="geolibre-project">', project_json, "</script>\n",
    "<script>\n(function () {\n",
    '  var frame = document.getElementById("geolibre-frame");\n',
    "  var project = JSON.parse(\n",
    '    document.getElementById("geolibre-project").textContent\n',
    "  );\n",
    "  var loaded = false;\n",
    "  function load() {\n",
    "    if (loaded || !frame.contentWindow) return;\n",
    "    loaded = true;\n",
    "    frame.contentWindow.postMessage(\n",
    '      { type: "geolibre:load-project", project: project, seq: 1 },\n',
    "      ", as.character(jsonlite::toJSON(origin, auto_unbox = TRUE)), "\n",
    "    );\n",
    "  }\n",
    "  // The application posts \"geolibre:ready\" once mounted; reply with the\n",
    "  // project. Guard on the frame as the source so an unrelated message\n",
    "  // cannot trigger the load.\n",
    '  window.addEventListener("message", function (event) {\n',
    "    if (event.source !== frame.contentWindow) return;\n",
    "    var data = event.data;\n",
    '    if (data && data.type === "geolibre:ready") load();\n',
    "  });\n",
    "})();\n</script>\n</body>\n</html>\n"
  )
  if (is.null(path)) return(html)
  if (!is_scalar_string(path) || !nzchar(path)) {
    stop_geolibre("`path` must be a single non-empty string.")
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(html, path, useBytes = TRUE)
  invisible(path)
}
