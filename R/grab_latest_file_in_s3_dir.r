grab_latest_file_in_s3_dir <- function(.path = s3path()) {
  paths <- system(paste('s3cmd ls ', .path, '*', sep = ''), intern = TRUE)
  times <- as.POSIXct(substring(paths, 1, 16))
  latest <- which(max(times) == times)
  regex <- paste(str_replace(.path, '\\/', '\\\\/'), '(.+)', sep = '')
  results <- gregexpr(regex, paths, perl = TRUE)
  substring(regmatches(paths, results)[[latest[1]]], 1 + nchar(.path))
}
