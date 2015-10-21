#' Determine whether object exists on S3
#' 
#' Test whether or not the given object exists at the 
#' give S3 path
#'
#' @param name string. Name of file to look for
#' @param path string. Path to file.  If missing, the entire s3 path must be provided in name.
#' @export
s3exists <- function(name, .path = s3path(), ...) {
  if (is.null(name)) return(FALSE)  # https://github.com/robertzk/s3mpi/issues/22
  s3key <- paste(.path, name, sep = "")
  s3key <- gsub("/$", "", s3key) # strip terminal /
  if (!grepl("^s3://", s3key)) stop("s3 paths must begin with \"s3://\"")
  s3cmd <- paste("s3cmd ls", s3key)
  results <- system(s3cmd, intern = TRUE)
  sum(grepl(paste(s3key, "(/[0-9A-Za-z]+)*/?$", sep = ""), results)) > 0
}


