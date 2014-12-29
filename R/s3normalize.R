s3normalize <- function(object, read = TRUE) {
  if (read)
    attr(object, "read") <- attr(object, "s3mpi.serialize")$read %||% identity
  else
    attr(object, "write") <- attr(object, "s3mpi.serialize")$write %||% identity
  object
