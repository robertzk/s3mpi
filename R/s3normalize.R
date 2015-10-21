## The roxygen documentation here is pretty thorough. In effect, if
## we wish to use s3mpi to store C, Java, etc. objects that are
## needed for our R code to run, we can do something like:
##
## ```r
## obj <- list(atomic_vector = 1:10, external_object = ptr_to_c_object)
## attr(obj, "s3mpi.serialize") <- list(
##   "write" = function(object) {
##      obj$external_object <- convert_ptr_to_raw_vector(obj$external_object)
##   },
##   "read" = function(object) {
##      obj$external_object <- convert_raw_vector_to_ptr(obj$external_object)
##   })
##
## s3store(obj, "some/key") # Will invoke the write function prior to 
##    # calling saveRDS and uploading the serialized object.
## s3read("some/key") # Will invoke the read function after downloading
##    # the serialized object and calling readRDS.
## ```
#' Convert a possibly non-serializable R object to a serializable R object.
#'
#' R has good foreign function interface bindings to C code. As such,
#' certain package authors may wish to optimize their code by keeping
#' their objects in C structures instead of R SEXPs (the standard for
#' object representation in the R interpreter). This also applies
#' to bindings to external libraries. The speed advantage can be
#' substantial, so this is not an uncommon use case. The \code{s3normalize}
#' helper provides the ability to add an additional "preprocessor"
#' layer prior to storing an object to S3 that converts a non-serializable
#' object (such as a list with one of its entries pointing to an 
#' external C structure) to serialize object (such as that list with
#' its C structure pointer entry replaced by a \code{\link{raw}} vector).
#'
#' If the object being uploaded with \code{s3store} or downloaded wiht
#' \code{s3read} has an attribute \code{"s3mpi.serialize"} which must
#' be a list with keys \code{c("read", "write")}, these keys should
#' hold functions requiring a single argument which are applied to
#' the object prior to \emph{reading} from (\code{s3read}) and \emph{writing}
#' to (\code{s3store}) S3, respectively. This allows s3mpi storage
#' of not only vanilla R objects but \emph{arbitrary objects in memory}
#' (whether they are internally represented by a C, Rust, Java, etc. process).
#' 
#' @param object ANY. The R object to normalize. If it has an
#'   \code{"s3mpi.serialize"} attribute consisting of a list with
#'   \code{"read"} and \code{"write"} keys, these arity-1 functions
#'   will be called with the \code{object} prior to reading from and
#'   writing to S3, respectively.
#' @param read logical. If \code{TRUE}, the \code{"read"} key of the
#'    \code{"s3mpi.serialize"} attribute, which should be a 1-argument
#'    function, will be invoked on the object. Otherwise, the \code{"write"}
#'    key will be invoked. By default, \code{read} is TRUE.
#' @return A previously possibly non-vanilla R object (that is, 
#'    an R object that may contain external pointers to non-R objects,
#'    such as vanilla C structs) converted to a totally vanilla R object
#'    (for example, by replacing the pointers with \code{\link{raw}} binary data).
#' @export
s3normalize <- function(object, read = TRUE) {
  if (utils::object.size(object) == 0) {
    warning("In s3mpi package: size-0 object is being normalized", call. = TRUE)
    NULL
  } else if (read) {
    (attr(object, "s3mpi.serialize")$read %||% identity)(object)
  } else {
    (attr(object, "s3mpi.serialize")$write %||% identity)(object)
  }
}

