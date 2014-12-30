s3normalize <- function(object, read = TRUE) {
  if (read)
    (attr(object, "s3mpi.serialize")$read %||% identity)(object)
  else
    (attr(object, "s3mpi.serialize")$write %||% identity)(object)
}
