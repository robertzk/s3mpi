#' Fetch an R object from an S3 path.
#'
#' @param path character. A full S3 path.
#' @param bucket.location character. Usually \code{"US"}.
#' @param verbose logical. If \code{TRUE}, the \code{s3cmd}
#'    utility verbose flag will be set.
#' @param debug logical. If \code{TRUE}, the \code{s3cmd}
#'    utility debug flag will be set.
#' @return The R object stored in RDS format on S3 in the \code{path}.
s3.get <- function (path, bucket.location = "US", verbose = FALSE, debug = FALSE) {
  ## This inappropriately-named function actually checks existence
  ## of a *path*, not a bucket. 
  AWS.tools:::check.bucket(path)

  # Helper function for fetching data from s3
  fetch <- function() {
    x.serialized <- tempfile()
    on.exit(unlink(x.serialized), add = TRUE)

    if (file.exists(x.serialized)) unlink(x.serialized, force = TRUE)
    s3.cmd <- paste("s3cmd get", path, x.serialized, paste("--bucket-location",
    bucket.location), ifelse(verbose, "--verbose --progress",
    "--no-progress"), ifelse(debug, "--debug", ""))
    system(s3.cmd)

    readRDS(x.serialized)
  }

  # Check for the path in the cache
  # If it does not exist, create and return its entry
  if (!s3LRUcache$exists(path)) {
    ans <- fetch()
    s3LRUcache$set(path, ans)
  } else {
    # Check time on s3LRUcache's copy
    last_cached <- s3LRUcache$last_accessed(path) # assumes a POSIXct object

    # Check time on s3 remote's copy
    s3.cmd <- paste("s3cmd ls ", path, "| awk '{print $1\" \"$2}' ")
    last_updated <- as.POSIXct(system(s3.cmd, intern = TRUE), tz="GMT")

    # Update the cache if remote is newer
    if (last_updated > last_cached) {
      ans <- fetch()
      s3LRUcache$set(path, ans)
    } else {
      ans <- s3LRUcache$get(path)
    }
  }
  ans
}
