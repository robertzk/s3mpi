#' @param x ANY. R object to store to S3.
#' @param name character.
#' @param check_exists logical. Whether or not to check if an object already exists at the specificed location.
#' @param num_retries numeric. the number of times to retry uploading.
#' @param backoff numeric. Vector, with each element in seconds, describing the
#'   exponential backoff to be used in conjunction with the num_retries argument.
#'   Number of elements must equal num_retries. Defaults to 4, 8, 16, 32, etc.
#' @param max_backoff numeric. Number describing the maximum seconds s3mpi will sleep
#'   prior to retrying an upload. Defaults to 128 seconds.
#' @rdname s3.get
s3.put <- function (x, path, name, bucket.location = "US",
                    debug = FALSE, check_exists = TRUE,
                    num_retries = getOption("s3mpi.num_retries", 0), backoff = 2 ^ seq(2, num_retries + 1),
                    max_backoff = 128) {
  s3key <- paste(path, name, sep = "")
  ## This inappropriately-named function actually checks existence
  ## of an entire *s3key*, not a bucket.
  AWS.tools:::check.bucket(s3key)

  ## Ensure backoff vector has correct number of elements and is capped
  if (num_retries > 0) {
    if (length(backoff) != num_retries) {
      stop("Your backoff vector length must match the number of retries.")
    }
    backoff <- pmin(backoff, max_backoff)
  }

  ## We create a temporary file, *write* the R object to the file, and then
  ## upload that file to S3. This magic works thanks to R's fantastic
  ## support for [arbitrary serialization](https://stat.ethz.ch/R-manual/R-patched/library/base/html/readRDS.html)
  ## (including closures!).
  x.serialized <- tempfile();
  dir.create(dirname(x.serialized), showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(x.serialized, force = TRUE), add = TRUE)
  saveRDS(x, x.serialized)

  s3.cmd <- paste("put", x.serialized, paste0('"', s3key, '"'),
            bucket_location_to_flag(bucket.location),
            ifelse(debug, "--debug", ""), "--force")

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
