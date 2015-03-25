#' Determine whether object exists on S3
#'
#' Test whether or not the given object exists at the
#' give S3 path
#'
#' @param name string. Name of file to look for
#' @param path string. Path to file.  If missing, the entire s3 path must be provided in name.

#' @export
s3exists <- function(name, .path = s3path(), ...) {
  s3key <- paste(.path, name, sep = '')
  s3key <- gsub('/$', '', s3key) # strip terminal /
  if (!grepl('^s3://', s3key)) stop("s3 paths must begin with \"s3://\"")
  s3cmd <- paste('aws s3 ls ', s3key)
  results <- suppressWarnings(system(s3cmd, intern=TRUE))
  filename <- as.data.frame(stringr::str_locate_all(pattern ='/', s3key))
  filename <- filename[NROW(filename), 1]
  filename <- str_sub(s3key, filename + 1, -1)
  sum(grepl(paste(filename, '(/[0-9A-Za-z]+)*/?$', sep=''), results)) > 0
}
