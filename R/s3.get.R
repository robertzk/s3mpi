#' Fetch an R object from an S3 path.
#'
#' @param path character. A full S3 path.
#' @param bucket.location character. Usually \code{"US"}.
#' @param verbose logical. If \code{TRUE}, the \code{s3cmd}
#'    utility verbose flag will be set.
#' @param debug logical. If \code{TRUE}, the \code{s3cmd}
#'    utility debug flag will be set.
#' @param cache logical. If \code{TRUE}, an LRU in-memory cache will be referenced.
#' @aliases s3.put
#' @return For \code{s3.get}, the R object stored in RDS format on S3 in the \code{path}.
#'    For \code{s3.put}, the system exit code from running the \code{s3cmd}
#'    command line tool to perform the upload.
s3.get <- function (path, bucket.location = "US", verbose = FALSE, debug = FALSE, cache = TRUE) {
  ## This inappropriately-named function actually checks existence
  ## of a *path*, not a bucket.
  AWS.tools:::check.bucket(path)

  # Helper function for fetching data from s3
  fetch <- function() {
    x.serialized <- tempfile()
    dir.create(dirname(x.serialized), showWarnings = FALSE, recursive = TRUE)
    ## We remove the file [when we exit the function](https://stat.ethz.ch/R-manual/R-patched/library/base/html/on.exit.html).
    on.exit(unlink(x.serialized), add = TRUE)

    if (file.exists(x.serialized)) {
      unlink(x.serialized, force = TRUE)
    }

    ## Run the s3cmd tool to fetch the file from S3.
    s3.cmd <- paste("get", paste0('"', path, '"'), x.serialized,
                    bucket_location_to_flag(bucket.location),
                    if (verbose) "--verbose --progress" else "--no-progress",
                    if (debug) "--debug" else "")
    system2(s3cmd(), s3.cmd)

    ## And then read it back in RDS format.
    readRDS(x.serialized)
  }

  ## Check for the path in the cache
  ## If it does not exist, create and return its entry.
  ## The `s3LRUcache` helper is defined in utils.R
  if (is.windows() || isTRUE(getOption("s3mpi.disable_lru_cache")) || !isTRUE(cache)) {
    ## We do not have awk, which we will need for the moment to
    ## extract the modified time of the S3 object.
    ans <- fetch()
  } else if (!s3LRUcache()$exists(path)) {
    ans <- fetch()
    ## We store the value of the R object in a *least recently used cache*,
    ## expecting the user to not think about optimizing their code and
    ## call `s3read` with the same key multiple times in one session. With
    ## this approach, we keep the latest 10 object in RAM and do not have
    ## to reload them into memory unnecessarily--a wise time-space trade-off!
    tryCatch(s3LRUcache()$set(path, ans), error = function(...) {
      warning("Failed to store object in LRU cache. Repeated calls to ",
              "s3read will not benefit from a performance speedup.")
    })
  } else {
    # Check time on s3LRUcache's copy
    last_cached <- s3LRUcache()$last_accessed(path) # assumes a POSIXct object

    # Check time on s3 remote's copy using the `s3cmd info` command.
    s3.cmd <- paste("info ", path, "| head -n 3 | tail -n 1")
    result <- system2(s3cmd(), s3.cmd, stdout = TRUE)
    # The `s3cmd info` command produces the output
    # "    Last mod:  Tue, 16 Jun 2015 19:36:10 GMT"
    # in its third line, so we subset to the 20-39 index range
    # to extract "16 Jun 2015 19:36:10".
    result <- substring(result, 20, 39)
    last_updated <- strptime(result, format = "%d %b %Y %H:%m:%S", tz = "GMT")

    if (last_updated > last_cached) {
      ans <- fetch()
      s3LRUcache()$set(path, ans)
    } else {
      ans <- s3LRUcache()$get(path)
    }
  }
  ans
}
