# Coercion of the many things a caller may hand to `add_*()` into the GeoJSON
# FeatureCollection and tabular-record shapes the project schema stores.

# Cap inlined sources so a huge file cannot silently exhaust memory once it is
# embedded in the project and re-serialized on every update.
MAX_INLINE_BYTES <- 50 * 1024^2

GEOJSON_GEOMETRY_TYPES <- c(
  "Point", "MultiPoint", "LineString", "MultiLineString",
  "Polygon", "MultiPolygon", "GeometryCollection"
)

is_http_url <- function(value) {
  is_scalar_string(value) && grepl("^https?://", value)
}

# Read a remote resource as text, bounded by `MAX_INLINE_BYTES`.
fetch_text <- function(url, what = "data") {
  connection <- tryCatch(
    base::url(url, open = "rb"),
    error = function(error) {
      stop_geolibre("Could not open ", what, " URL ", url, ": ", conditionMessage(error))
    }
  )
  on.exit(close(connection), add = TRUE)
  chunks <- list()
  total <- 0
  repeat {
    chunk <- tryCatch(
      readBin(connection, "raw", n = 1024L^2L),
      error = function(error) {
        stop_geolibre("Could not read ", what, " from ", url, ": ", conditionMessage(error))
      }
    )
    if (!length(chunk)) break
    total <- total + length(chunk)
    if (total > MAX_INLINE_BYTES) {
      stop_geolibre(
        "Response from ", url, " exceeds the ",
        MAX_INLINE_BYTES %/% 1024L^2L, " MB inline size limit."
      )
    }
    chunks[[length(chunks) + 1L]] <- chunk
  }
  text <- rawToChar(if (length(chunks)) do.call(c, chunks) else raw(0))
  Encoding(text) <- "UTF-8"
  text
}

read_local_text <- function(path, what = "data") {
  if (file.size(path) > MAX_INLINE_BYTES) {
    stop_geolibre(
      what, " file exceeds the ", MAX_INLINE_BYTES %/% 1024L^2L,
      " MB inline size limit: ", path
    )
  }
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

# Convert an `sf`/`sfc`/`sfg` object to a GeoJSON FeatureCollection list,
# transforming to EPSG:4326 first.
sf_to_geojson <- function(data) {
  require_suggested("sf", "reading sf objects")
  if (inherits(data, "sfg")) data <- sf::st_sfc(data)
  data <- sf::st_as_sf(data)
  if (is.na(sf::st_crs(data))) {
    # GeoJSON is longitude/latitude by definition. Taking bare coordinates at
    # face value also keeps the writer from substituting an engineering CRS and
    # warning about it.
    sf::st_crs(data) <- 4326
  } else {
    data <- sf::st_transform(data, 4326)
  }
  path <- tempfile(fileext = ".geojson")
  on.exit(unlink(path), add = TRUE)
  sf::st_write(data, path, driver = "GeoJSON", quiet = TRUE)
  collection <- jsonlite::read_json(path, simplifyVector = FALSE)
  # Drop what the writer adds and the project does not need: the temporary file's
  # name, which would otherwise leak a random path into every saved project, and
  # a `crs` block that only restates GeoJSON's own CRS84 default.
  collection$name <- NULL
  collection$crs <- NULL
  collection
}

# Coerce assorted inputs into a GeoJSON FeatureCollection list. Accepts an `sf`,
# `sfc`, or `sfg` object, a parsed GeoJSON list (FeatureCollection, Feature, or
# bare geometry), a JSON string, a file path, or an HTTP(S) URL.
as_featurecollection <- function(data) {
  if (inherits(data, c("sf", "sfc", "sfg"))) {
    data <- sf_to_geojson(data)
  }
  if (is_scalar_string(data)) {
    text <- if (is_http_url(data)) {
      fetch_text(data, "GeoJSON")
    } else if (file.exists(data)) {
      read_local_text(data, "GeoJSON")
    } else {
      data
    }
    data <- tryCatch(
      jsonlite::fromJSON(text, simplifyVector = FALSE),
      error = function(error) {
        stop_geolibre("`data` is not valid GeoJSON: ", conditionMessage(error))
      }
    )
  }
  if (!is.list(data)) {
    stop_geolibre("`data` must be GeoJSON, a path, a URL, JSON text, or an sf object.")
  }
  type <- data$type
  if (!is_scalar_string(type)) {
    stop_geolibre("GeoJSON must have a single string `type`.")
  }
  if (identical(type, "FeatureCollection")) {
    if (is.null(data$features)) data$features <- empty_array()
    if (!is.list(data$features)) {
      stop_geolibre("A GeoJSON FeatureCollection must contain a `features` list.")
    }
    return(data)
  }
  if (identical(type, "Feature")) {
    return(list(type = "FeatureCollection", features = list(data)))
  }
  if (type %in% GEOJSON_GEOMETRY_TYPES) {
    return(list(
      type = "FeatureCollection",
      features = list(list(type = "Feature", properties = empty_object(), geometry = data))
    ))
  }
  stop_geolibre("Unsupported GeoJSON type: ", type)
}

# Read a local vector dataset (Shapefile, GeoPackage, GeoParquet, FlatGeobuf,
# KML, ...) with sf and inline it as GeoJSON. The browser cannot reach a file on
# the R session's host, so a local dataset is read here rather than streamed by
# the in-browser vector control.
read_local_vector <- function(path, source_layer = NULL) {
  require_suggested("sf", "reading local vector files")
  if (!file.exists(path)) {
    stop_geolibre("Vector file not found: ", path)
  }
  args <- list(dsn = path, quiet = TRUE)
  if (!is.null(source_layer)) args$layer <- source_layer
  data <- tryCatch(
    do.call(sf::st_read, args),
    error = function(error) {
      stop_geolibre("Could not read vector file ", path, ": ", conditionMessage(error))
    }
  )
  sf_to_geojson(data)
}

point_feature <- function(lng, lat, properties = NULL) {
  if (!is.null(properties)) {
    if (!is.list(properties) ||
        (length(properties) &&
          (is.null(names(properties)) || any(!nzchar(names(properties)))))) {
      stop_geolibre("`properties` must be NULL or a named list.")
    }
  }
  list(
    type = "Feature",
    geometry = list(type = "Point", coordinates = c(as.numeric(lng), as.numeric(lat))),
    properties = if (length(properties)) properties else empty_object()
  )
}

# Coerce assorted point inputs into a point FeatureCollection: anything
# `as_featurecollection()` accepts, plus a matrix or data frame of coordinates
# and a list of `c(lng, lat)` pairs or named `list(lng =, lat =, ...)` entries.
points_to_featurecollection <- function(points) {
  looks_like_geojson <- inherits(points, c("sf", "sfc", "sfg")) ||
    is_scalar_string(points) ||
    (is.list(points) && !is.data.frame(points) && is_scalar_string(points$type))
  if (looks_like_geojson) {
    collection <- as_featurecollection(points)
    for (feature in collection$features) {
      geometry_type <- if (is.list(feature)) feature$geometry$type else NULL
      if (!is_scalar_string(geometry_type) ||
          !(geometry_type %in% c("Point", "MultiPoint"))) {
        stop_geolibre(
          "Marker layers require Point/MultiPoint geometries; got ",
          if (is.null(geometry_type)) "none" else geometry_type,
          ". Use add_geojson() for other geometries."
        )
      }
    }
    return(collection)
  }
  rows <- if (is.data.frame(points)) {
    lapply(seq_len(nrow(points)), function(i) as.list(points[i, , drop = FALSE]))
  } else if (is.matrix(points)) {
    lapply(seq_len(nrow(points)), function(i) as.numeric(points[i, ]))
  } else if (is.list(points)) {
    points
  } else {
    stop_geolibre(
      "`points` must be a matrix or data frame of coordinates, a list of ",
      "c(longitude, latitude) pairs or named entries, GeoJSON, or an sf object."
    )
  }
  features <- lapply(seq_along(rows), function(index) {
    entry <- rows[[index]]
    if (is.list(entry) && !is.null(names(entry))) {
      lng <- first_present(entry, c("lng", "lon", "long", "longitude", "x"))
      lat <- first_present(entry, c("lat", "latitude", "y"))
      if (is.null(lng) || is.null(lat)) {
        stop_geolibre(
          "Entry ", index, " needs longitude (lng/lon/long/longitude/x) and ",
          "latitude (lat/latitude/y) values."
        )
      }
      if (!is_scalar_number(lng) || !is_scalar_number(lat)) {
        stop_geolibre(
          "Entry ", index,
          " longitude and latitude must each be one finite numeric value."
        )
      }
      properties <- entry[setdiff(
        names(entry),
        c("lng", "lon", "long", "longitude", "x", "lat", "latitude", "y")
      )]
      point_feature(lng, lat, properties)
    } else {
      pair <- unlist(entry, use.names = FALSE)
      if (!is.numeric(pair) || length(pair) != 2L || any(!is.finite(pair))) {
        stop_geolibre("Entry ", index, " must be a c(longitude, latitude) pair.")
      }
      point_feature(pair[[1]], pair[[2]])
    }
  })
  list(type = "FeatureCollection", features = features)
}

first_present <- function(entry, keys) {
  for (key in keys) {
    if (!is.null(entry[[key]])) return(entry[[key]])
  }
  NULL
}

# Convert a data frame, CSV path/URL/text, or list of row lists into records.
tabular_records <- function(data) {
  if (is.data.frame(data)) {
    return(lapply(seq_len(nrow(data)), function(i) as.list(data[i, , drop = FALSE])))
  }
  if (is_scalar_string(data)) {
    text <- if (is_http_url(data)) {
      fetch_text(data, "CSV")
    } else if (file.exists(data)) {
      read_local_text(data, "CSV")
    } else {
      data
    }
    frame <- tryCatch(
      utils::read.csv(
        text = text,
        stringsAsFactors = FALSE,
        check.names = FALSE,
        colClasses = NA
      ),
      error = function(error) {
        stop_geolibre("Could not parse `data` as CSV: ", conditionMessage(error))
      }
    )
    return(lapply(seq_len(nrow(frame)), function(i) as.list(frame[i, , drop = FALSE])))
  }
  if (!is.list(data)) {
    stop_geolibre("`data` must be a data frame, a CSV path, a CSV URL, CSV text, or a list of rows.")
  }
  lapply(data, as.list)
}
