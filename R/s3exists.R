#' Determine whether object exists on S3
#' 
#' Test whether or not the given object exists at the 
#' give S3 path
#'
#' @param name string. Name of file to look for
#' @param path string. Path to file

#' @export
s3exists <- function(name, .path, ...) {
  s3key <- if (missing(.path)) name else paste(.path, name, sep = '')
  if (!grepl('^s3://', s3key)) stop("s3 paths must begin with \"s3://\"")
  s3cmd <- paste('s3cmd ls', s3key)
  results <- system(s3cmd, intern=TRUE)
  length(results) > 0
}
