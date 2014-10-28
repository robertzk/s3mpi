#' Determine whether object exists on S3
#' 
#' Test whether or not the given object exists at the 
#' give S3 path
#'
#' @param name string. Name of file to look for
#' @param path string. Path to file

#' @export
s3exists <- function(name, .path = s3path(), ...) { 
  s3key <- paste(.path, name, sep = '')
  s3cmd <- paste('s3cmd ls', s3key)
  results <- system(s3cmd, intern=TRUE)
  length(results) > 0
}
