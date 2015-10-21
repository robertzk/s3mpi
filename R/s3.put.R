# Overwrite AWS.tools::s3.put because we would like to check md5.
s3.put <- function (x, bucket, bucket.location = "US", verbose = FALSE,
                    debug = FALSE, encrypt = FALSE) {
  ## This inappropriately-named function actually checks existence
  ## of a *path*, not a bucket. 

  AWS.tools:::check.bucket(bucket)
  ## We create a temporary file, *write* the R object to the file, and then
  ## upload that file to S3. This magic works thanks to R's fantastic 
  ## support for [arbitrary serialization](https://stat.ethz.ch/R-manual/R-patched/library/base/html/readRDS.html)
  ## (including closures!).
  x.serialized <- tempfile()
  on.exit(unlink(x.serialized, force = TRUE), add = TRUE)
  saveRDS(x, x.serialized)

  s3.cmd <- paste("s3cmd put", x.serialized, bucket, ifelse(encrypt,
      "--encrypt", ""), paste("--bucket-location", bucket.location),
      ifelse(verbose, "--verbose --progress", "--no-progress"), ifelse(debug,
          "--debug", ""), '--check-md5')

  system(s3.cmd, intern = TRUE)
}

