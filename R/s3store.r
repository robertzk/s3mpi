#' Store an R object in S3 by key
#'
#' Any type of object that can be serialized as an RDS file
#' is capable of being retrieved using this interface.
#'
#' @export
#' @param obj ANY. An R object to save to S3.
#' @param name character. The S3 key to save to.
#' @param .path character. The S3 prefix, e.g., "s3://yourbucket/some/path/".
#' @param safe logical. Whether or not to overwrite existing fails by
#'    default or error if they exist.
#' @param ... additional arguments to \code{s3mpi:::s3.put}.
#' @examples
#' \dontrun{
#' s3store(c(1,2,3), 'test123')
#' print(s3read('test123'))
#' # [1] 1 2 3
<<<<<<< HEAD
#' }#' 
s3store <- function(obj, name = NULL, .path = s3path(), safe = FALSE, ...) {
||||||| merged common ancestors
#' }#' 
s3store <- function(obj, name = NULL, .path = s3path(), ...) {
=======
#' }#'
s3store <- function(obj, name = NULL, .path = s3path(), safe = TRUE, ...) {
>>>>>>> master
  if (is.null(name)) name <- deparse(substitute(obj))
  s3key <- paste(.path, name, sep = '')
  if (safe && s3mpi::s3exists(name, .path = .path, ...)) {
    # using cat prints to stdout as opposed to messages, so it can be seen from syberia::run_model()
    cat(paste("An object with name", name, "on path", .path, "already exists. Use `safe = FALSE` to overwrite\n"))
    stop("-------------------------^")
  }
  obj4save <- s3normalize(obj, FALSE)
  s3mpi:::s3.put(obj4save, s3key, ...)
  if (!is.null(getOption('s3mpi.cache'))) s3cache(s3key, obj4save)
  invisible(s3key)
}

#' @export
#' @rdname s3store
#' @note \code{s3put} is equivalent to \code{s3store} except that
#'    it will fail by default if you try to overwrite an existing key.
s3put <- function(..., safe = TRUE) { s3store(..., safe = safe) }
