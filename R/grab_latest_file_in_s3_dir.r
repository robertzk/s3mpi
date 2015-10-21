#' Find the latest modified file with a given S3 prefix.
#'
#' @note This helper function is used when no input key
#'    is specified to the \code{\link{s3read}} function to fetch the
#'    latest modified file in that bucket. If the bucket has
#'    many files, this can be very slow.
#' @param path character. The S3 prefix to search for the
#'    latest uploaded key.
grab_latest_file_in_s3_dir <- function(path = s3path()) {
  ensure_s3cmd_present()

  paths   <- system2("s3cmd", "ls", paste0(path, "*"), stdout = TRUE)
  times   <- as.POSIXct(substring(paths, 1, 16))
  latest  <- which(max(times) == times)
  regex   <- paste(string::str_replace(path, "\\/", "\\\\/"), "(.+)", sep = "")
  results <- gregexpr(regex, paths, perl = TRUE)
  substring(regmatches(paths, results)[[latest[1]]], 1 + nchar(path))
}

