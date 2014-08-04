function (bucket, bucket.location = "US", verbose = FALSE, debug = FALSE) {
  check.bucket(bucket)
  x.serialized <- tempfile()
  s3.cmd <- paste("s3cmd get", bucket, x.serialized, paste("--bucket-location",
      bucket.location), ifelse(verbose, "--verbose --progress",
      "--no-progress"), ifelse(debug, "--debug", ""))
  res <- system(s3.cmd, intern = TRUE)
  ans <- readRDS(x.serialized)
  unlink(x.serialized)
  ans
}
