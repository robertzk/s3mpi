#' Read an R object in S3 by key
#' 
#' Any type of object that can be serialized as an RDS file
#' is capable of being stored using this interface.
#'
#' @param name character. The key to grab from S3.
#' @param .path. The location of your S3 bucket.
#' @param cache logical. If true, use the local s3cache if available.  If false, do not use cache.
#'
#' @export
#' @examples
#' \dontrun{
#' s3store(c(1,2,3), 'test123')
#' print(s3read('test123'))
#' # [1] 1 2 3
#' } 
s3read <- function(name = NULL, .path = s3path(), cache = TRUE, ...) { 
  if (is.null(name)) name <- grab_latest_file_in_s3_dir(.path)
  s3key <- paste(.path, name, sep = '')

  if (substr(.path, nchar(.path), nchar(.path)) != "/") { .path <- paste0(.path, "/") }

  if (!isTRUE(cache) || is.null(getOption('s3mpi.cache'))) {
    value <- s3.get(s3key, ...)
  } else if (is.not_cached(value <- s3cache(s3key))) {
    value <- s3.get(s3key, ...)
    s3cache(s3key, value)
  }
  s3normalize(value, TRUE)
}
