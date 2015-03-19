s3normalize <- function(object, read = TRUE) {
  if (object.size(object) == 0) {
    warning("Size-0 object is being normalized", call. = TRUE)
    return(NULL)
  }
  if (read)
    (attr(object, "s3mpi.serialize")$read %||% identity)(object)
  else
    (attr(object, "s3mpi.serialize")$write %||% identity)(object)
}
