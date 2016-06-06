#' Delete an R object from S3 by key
#'
#' @seealso \code{\link{s3store}}
#' @param key character. The key to delete from S3.
#' @param path character. The location of your S3 bucket as a prefix to \code{name},
#'    for example, \code{"s3://mybucket/"} or \code{"s3://mybucket/myprefix/"}.
#' @export
s3delete <- function(key, path = s3path()) {
  path <- add_ending_slash(path)
  system2(s3cmd(), paste0("del ", path, "/", key))
}
