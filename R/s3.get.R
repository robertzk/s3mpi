s3.get <- function (bucket) {
  AWS.tools:::check.bucket(bucket)
  x.serialized <- tempfile()
  s3.cmd <- paste0("s3 cp ", bucket, " ", x.serialized)
  status <- system2('aws', s3.cmd)
  if (as.logical(status)) {
    warning("Nothing exists for key ", bucket)
    ans <- data.frame()
    class(ans) <- c("s3mpi_error", class(ans))
    attr(ans, "key") <- bucket
  } else {
    ans <- readRDS(x.serialized)
  }
  unlink(x.serialized)
  ans
}
