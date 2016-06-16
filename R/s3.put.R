#' @param encrypt logical. Whether or not to encrypt the serialized R
#'    object prior to upload it to S3.
#' @param x ANY. R object to store to S3.
#' @param name character.
#' @param num_retries numeric. the number of times to retry uploading.
#' @param check_exists logical. Wheter or not to check if an object already exists at the specificed location.
#' @rdname s3.get
s3.put <- function (x, path, name, bucket.location = "US", verbose = FALSE,
                    debug = FALSE, encrypt = FALSE, check_exists = TRUE,
                    num_retries = getOption("s3mpi.num_retries", 0), backoff = c(2,8,32,64,128)) {
  s3key <- paste(path, name, sep = "")
  ## This inappropriately-named function actually checks existence
  ## of an entire *s3key*, not a bucket.
  AWS.tools:::check.bucket(s3key)

  ## We create a temporary file, *write* the R object to the file, and then
  ## upload that file to S3. This magic works thanks to R's fantastic
  ## support for [arbitrary serialization](https://stat.ethz.ch/R-manual/R-patched/library/base/html/readRDS.html)
  ## (including closures!).
  x.serialized <- tempfile();
  dir.create(dirname(x.serialized), showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(x.serialized, force = TRUE), add = TRUE)
  saveRDS(x, x.serialized)

  s3.cmd <- paste("put", x.serialized, paste0('"', s3key, '"'), ifelse(encrypt,
      "--encrypt", ""), paste("--bucket-location", bucket.location),
      ifelse(verbose, "--verbose --progress", "--no-progress"), ifelse(debug,
          "--debug", ""), '--check-md5')

  ## Ensure backoff vector has correct number of elements and is capped
  if (num_retries > 0) {
    backoff <- backoff[vapply(1:num_retries, function(i) min(i, length(backoff)), integer(1))]
  }
  run_system_put(path, name, s3.cmd, check_exists, num_retries, backoff)
}

run_system_put <- function(path, name, s3.cmd, check_exists, num_retries, backoff) {
  ret <- system2(s3cmd(), s3.cmd, stdout = TRUE)
  if (isTRUE(check_exists) && !s3exists(name, path)) {
    if (num_retries > 0) {
      Sys.sleep(backoff[length(backoff) - num_retries + 1])
      do.call(Recall, `$<-`(as.list(match.call()[-1]), "num_retries", num_retries - 1))
    } else {
      stop("Object could not be successfully stored.")
    }
  } else {
    ret
  }
}
