#' @export
print.s3mpi_error <-
  function(x, ...)
    cat("An error occured while reading from bucket: ", attr(x, "key"), "\n")
