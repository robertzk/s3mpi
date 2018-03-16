#' Determine whether object exists on S3.
#'
#' Test whether or not the given object exists at the
#' give S3 path.
#'
#' @param name string. Name of file to look for
#' @param path string. Path to file.  If missing, the entire s3 path must be provided in name.
#' @export
#' @examples \dontrun{
#' s3exists("my/key") # Will look in bucket given by getOption("s3mpi.path") or
#' from a system environment variable.
#'   # For example, if this option is "s3://mybucket/", then this query
#'   # will check for existence of the \code{s3://mybucket/my/key} S3 path.
#'
#' s3exists("my/key", "s3://anotherbucket/") # We can of course change the bucket.
#' }
s3exists <- function(name, path = s3path()) {
  if (is.null(name)) return(FALSE)  # https://github.com/robertzk/s3mpi/issues/22
  path  <- add_ending_slash(path)
  s3key <- paste(path, name, sep = "")
  s3key <- gsub("/$", "", s3key) # strip terminal /
  if (!grepl("^s3://", s3key)) {
    stop("s3 paths must begin with \"s3://\"")
  }

  results <- system2(s3cmd(), s3cmd_exists_command(s3key), stdout = TRUE)

  ## We know that the key exists if a result was returned, i.e., the
  ## shown regex gives a match.
  sum(grepl(paste0(name, "(/[0-9A-Za-z]+)*/?$"), results)) > 0
}

s3cmd_exists_command <- function(s3key) {
  if (use_legacy_api()) {
    paste("ls", s3key)
  } else {
    paste("s3", "ls", s3key)
  }
}
