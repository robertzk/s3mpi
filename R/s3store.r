#' Store an R object in S3 by key.
#'
#' Any type of object that can be serialized as an RDS file
#' is capable of being retrieved using this interface.
#'
#' If you wish to store non-vanilla R objects, such as those
#' containing external pointers to C structures, see
#' \code{\link{s3normalize}}.
#'
#' @export
#' @seealso \code{\link{s3read}}
#' @param obj ANY. An R object to save to S3.
#' @param name character. The S3 key to save to. If no key is provided,
#'    the expression passed as \code{obj} will be used.
#' @param path character. The S3 prefix, e.g., "s3://yourbucket/some/path/".
#' @param safe logical. Whether or not to overwrite existing fails by
#'    default or error if they exist.
#' @param ... additional arguments to \code{s3mpi:::s3.put}.
#' @examples
#' \dontrun{
#' s3store(c(1,2,3), 'test123')
#' print(s3read('test123'))
#' # [1] 1 2 3
#'
#' s3store(function(x, y) { x + 2 * y }, "myfunc")
#' stopifnot(s3read("myfunc")(1, 2) == 5) # R can serialize closures!
#'
#' obj <- 1:5
#' s3store(obj) # If we do not pass a key the path is inferred from
#'   # the expression using deparse(substitute(...)).
#' stopifnot(all.equal(s3read("obj"), 1:5))
#' }
s3store <- function(obj, name = NULL, path = s3path(), safe = FALSE, ...) {
  if (missing(name)) {
    name <- deparse(substitute(obj))
  }

  path <- add_ending_slash(path)

  s3key <- paste(path, name, sep = "")
  if (isTRUE(safe) && s3exists(name, path = path, ...)) {
    stop("An object with name ", name, " on path ", path,
        " already exists. Use `safe = FALSE` to overwrite\n",
        "-----------------------^")
  }

  obj4save <- s3normalize(obj, FALSE)
  s3.put(obj4save, path, name, ...)

  if (!is.null(getOption("s3mpi.cache"))) {
    s3cache(s3key, obj4save)
  }

  if (is.environment(obj4save)) {
    s3normalize(obj4save) # Revert side effects
  }

  invisible(s3key)
}

#' @export
#' @rdname s3store
#' @note \code{s3put} is equivalent to \code{s3store} except that
#'    it will fail by default if you try to overwrite an existing key.
s3put <- function(..., safe = TRUE) {
  s3store(..., safe = safe)
}
