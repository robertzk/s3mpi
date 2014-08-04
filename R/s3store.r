#' Store an R object in S3 by key
#' 
#' Any type of object that can be serialized as an RDS file
#' is capable of being retrieved using this interface.
#'
#' @export
#' @examples
#' \dontrun{
#' s3store(c(1,2,3), 'test123')
#' print(s3read('test123'))
#' # [1] 1 2 3
#' }#' 
s3store <- function(obj, name = NULL, .path = s3path(), ...) {
  if (is.null(name)) name <- deparse(substitute(obj))
  s3key <- paste(.path, name, sep = '')
  s3mpi:::s3.put(obj, s3key, ...)
  s3cache(s3key, obj)
  invisible(s3key)
}
  
