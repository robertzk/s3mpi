#' @param encrypt logical. Whether or not to encrypt the serialized R
#'    object prior to upload it to S3.
#' @param x ANY. R object to store to S3.
#' @rdname s3.get
s3.put <- function (x, path, bucket.location = "US", verbose = FALSE,
                    debug = FALSE, encrypt = FALSE) {
  ## This inappropriately-named function actually checks existence
  ## of a *path*, not a bucket.
  AWS.tools:::check.bucket(path)

  ## We create a temporary file, *write* the R object to the file, and then
  ## upload that file to S3. This magic works thanks to R's fantastic
  ## support for [arbitrary serialization](https://stat.ethz.ch/R-manual/R-patched/library/base/html/readRDS.html)
  ## (including closures!).
  x.serialized <- tempfile(); on.exit(unlink(x.serialized, force = TRUE), add = TRUE)
  saveRDS(x, x.serialized)

  s3.cmd <- paste("put", x.serialized, paste0('"', path, '"'), ifelse(encrypt,
      "--encrypt", ""), paste("--bucket-location", bucket.location),
      ifelse(verbose, "--verbose --progress", "--no-progress"), ifelse(debug,
          "--debug", ""), '--check-md5')

  system2(s3cmd(), s3.cmd, stdout = TRUE)
}
