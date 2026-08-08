# Benchmark the installed `geolibre` package in a clean R process.
#
# Usage:
#   Rscript benchmarks/add-xy-data.R LIBRARY OUTPUT.csv [OUTPUT.rds]
#
# Run once against an isolated baseline installation and once against an
# isolated candidate installation. Compare the CSV timing distributions and
# the optional canonicalized RDS outputs separately.
#
# Observed on 2026-08-08 with R 4.5.0 on aarch64-apple-darwin20, using commit
# cb37ec0 as the baseline and 7 iterations at 10,000 rows / 5 at 100,000 rows:
#
# | Rows    | Baseline | Candidate | Speedup | Object size |
# |---------|----------|-----------|---------|-------------|
# | 10,000  | 0.301 s  | 0.052 s   | 5.79x   | 16.96 MB    |
# | 100,000 | 3.260 s  | 0.551 s   | 5.92x   | 169.39 MB   |
#
# The canonicalized 10,000-row widgets were identical. Absolute timings vary
# by machine; the benchmark records the environment with each result.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Usage: add-xy-data.R LIBRARY OUTPUT.csv [OUTPUT.rds]", call. = FALSE)
}

library_path <- normalizePath(args[[1]], mustWork = TRUE)
output_csv <- args[[2]]
output_rds <- if (length(args) >= 3L) args[[3]] else NULL
.libPaths(c(library_path, .libPaths()))
library(geolibre)

make_points <- function(n) {
  data.frame(
    id = seq_len(n),
    longitude = runif(n, -180, 180),
    latitude = runif(n, -80, 80),
    value = rnorm(n),
    group = sample(letters, n, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

measure <- function(data, iterations) {
  times <- numeric(iterations)
  result <- NULL
  for (iteration in seq_len(iterations)) {
    # Drop the previous widget before collecting, so the freed memory cannot
    # push a collection into the timed call below.
    result <- NULL
    gc(FALSE)
    times[[iteration]] <- system.time(
      result <- add_xy_data(geolibre(), data)
    )[["elapsed"]]
  }
  list(times = times, result = result)
}

set.seed(20260808)
fixtures <- list(`10000` = make_points(10000L), `100000` = make_points(100000L))
invisible(add_xy_data(geolibre(), fixtures[[1]][seq_len(100L), ]))

rows <- list()
saved <- list()
for (size in names(fixtures)) {
  iterations <- if (identical(size, "10000")) 7L else 5L
  measured <- measure(fixtures[[size]], iterations)
  rows[[size]] <- data.frame(
    package_version = as.character(utils::packageVersion("geolibre")),
    r_version = paste(R.version$major, R.version$minor, sep = "."),
    platform = R.version$platform,
    rows = as.integer(size),
    iterations = iterations,
    median_seconds = median(measured$times),
    min_seconds = min(measured$times),
    max_seconds = max(measured$times),
    object_mb = as.numeric(object.size(measured$result)) / 1024^2
  )
  if (identical(size, "10000")) {
    measured$result$x$project$layers[[1]]$id <- "<generated-id>"
    saved[[size]] <- measured$result
  }
}

utils::write.csv(do.call(rbind, rows), output_csv, row.names = FALSE)
if (!is.null(output_rds)) saveRDS(saved, output_rds, version = 3)
