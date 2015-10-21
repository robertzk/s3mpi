#' Fetch an R object from an S3 path.
#'
#' @param path character. A full S3 path.
#' @param bucket.location character. Usually \code{"US"}.
#' @param verbose logical. If \code{TRUE}, the \code{s3cmd}
#'    utility verbose flag will be set.
#' @param debug logical. If \code{TRUE}, the \code{s3cmd}
#'    utility debug flag will be set.
#' @aliases s3.put
#' @return For \code{s3.get}, the R object stored in RDS format on S3 in the \code{path}.
#'    For \code{s3.put}, the system exit code from running the \code{s3cmd}
#'    command line tool to perform the upload.
s3.get <- function (path, bucket.location = "US", verbose = FALSE, debug = FALSE) {
  ## This inappropriately-named function actually checks existence
  ## of a *path*, not a bucket. 
  AWS.tools:::check.bucket(path)

  # Helper function for fetching data from s3
  fetch <- function() {
    x.serialized <- tempfile()
    ## We remove the file [when we exit the function](https://stat.ethz.ch/R-manual/R-patched/library/base/html/on.exit.html).
    on.exit(unlink(x.serialized), add = TRUE)

    if (file.exists(x.serialized)) {
      unlink(x.serialized, force = TRUE)
    }

    ## Run the s3cmd tool to fetch the file from S3.
    s3.cmd <- paste("s3cmd get", path, x.serialized, paste("--bucket-location",
      bucket.location), ifelse(verbose, "--verbose --progress",
      "--no-progress"), ifelse(debug, "--debug", ""))
    system(s3.cmd)

    ## And then read it back in RDS format.
    readRDS(x.serialized)
  }

  # Check for the path in the cache
  # If it does not exist, create and return its entry.
  ## The `s3LRUcache` helper is defined 
  if (is.windows()) {
    ## We do not have awk, which we will need for the moment to
    ## extract the modified time of the S3 object. 
    ans <- fetch()
  } else if (!s3LRUcache$exists(path)) {
    ans <- fetch()
    ## We store the value of the R object in a *least recently used cache*,
    ## expecting the user to not think about optimizing their code and
    ## call `s3read` with the same key multiple times in one session. With
    ## this approach, we keep the latest 10 object in RAM and do not have
    ## to reload them into memory unnecessarily--a wise time-space trade-off!
    s3LRUcache$set(path, ans)
  } else {
    # Check time on s3LRUcache's copy
    last_cached <- s3LRUcache$last_accessed(path) # assumes a POSIXct object

    # Check time on s3 remote's copy
    s3.cmd <- paste("s3cmd ls ", path, "| awk '{print $1\" \"$2}' ")
    last_updated <- as.POSIXct(system(s3.cmd, intern = TRUE), tz="GMT")

    # Update the cache if remote is newer.
    if (last_updated > last_cached) {
      ans <- fetch()
      s3LRUcache$set(path, ans)
    } else {
      ans <- s3LRUcache$get(path)
    }
  }
  ans
}

