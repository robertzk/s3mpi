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
s3store <- function(obj, name = NULL, .path = s3path(), safe = TRUE, ...) {
  if (is.null(name)) name <- deparse(substitute(obj))
  s3key <- paste(.path, name, sep = '')
  if (safe && s3mpi::s3exists(name, .path = s3path(), ...)) {
    stop("An object with this name already exists. Use `safe = FALSE` to overwrite")
  }
  obj4save <- s3normalize(obj, FALSE)
  s3mpi:::s3.put(obj4save, s3key, ...)
  if (!is.null(getOption('s3mpi.cache'))) s3cache(s3key, obj4save)
  invisible(s3key)
}
