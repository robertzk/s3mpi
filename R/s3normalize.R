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

