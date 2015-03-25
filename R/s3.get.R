s3.get <- function (bucket) {
  AWS.tools:::check.bucket(bucket)
  x.serialized <- tempfile()
  s3.cmd <- paste0("aws s3 cp ", bucket, " ", x.serialized)
  system(s3.cmd)
  ans <- readRDS(x.serialized)
  unlink(x.serialized)
  ans
}
