## If we are frequently using `s3read` and `s3store` from within an
## active R session, it is likely that we will need to pull the stored
## object multiple times. For example, if we have the training data
## set for a model or a list with some summary statistics, we may be
## pulling this frequently when performing analysis during a week-long
## project.
##
## To facilitate this process and speed things up a bit, we keep a
## local *file system cache* of the objects downloaded from S3 using
## `s3read`. If the user has set their `s3mpi.cache` option to a
## directory path (by default `~/.s3cache`), we will use that directory
## to store downloaded R objects. The second time a user calls
## `s3read("some/key")` we will fetch it from the local file system
## instead of spending time re-downloading the object.
##
## This functionality should be disabled if we regularly are storing
## and pulling objects that in aggregate exceed the user's available disk space.
#' A caching layer around s3mpi calls.
#'
#' Fetching large files from the S3 MPI can be expensive when performed
#' multiple times. This method allows one to add a caching layer
#' around S3 fetching. The user should specify the configuration option
#' \code{options(s3mpi.cache = "some/dir")}. The recommended cache
#' directory (where files will be stored) is \code{"~/.s3cache"}.
#'
#' @param s3key character. The full S3 key to attempt to read or write
#'    to the cache.
#' @param value ANY. The R object to save in the cache. If missing,
#'    a cache read will be performed instead.
s3cache <- function(s3key, value) {
  if (!cache_enabled()) {
    stop("Cannot use s3mpi::s3cache until you set options(s3mpi.cache) ",
         "to a directory in which to place cache contents.")
  }

  d <- cache_directory()
  dir.create(d, FALSE, TRUE)
  ## We will hold the objects in the `data` subdirectory of the `s3mpi.cache`
  ## path and *metadata* about the objects (such as when it was last modified
  ## on S3, so we can perform cache invalidation) in the `info` directory.
  dir.create(file.path(d, "info"), FALSE, TRUE)
  dir.create(file.path(d, "data"), FALSE, TRUE)

  # If no value to store was provided, we assume we are reading from the cache.
  if (missing(value)) {
    fetch_from_cache(s3key, d)
  } else { # Otherwise, we are writing to it.
    save_to_cache(s3key, value, d)
  }
}

#' Helper function for fetching a file from a cache directory.
#'
#' This function will also test to determine whether the file has been
#' modified on S3 since the last cache save. If the file has never been
#' cached or the cache is invalidated, it will return \code{s3mpi::not_cached}.
#'
#' @param key character. The key under which the cache entry is stored.
#' @param cache_dir character. The cache directory. The default is
#'    \code{cache_directory()}.
#' @return the cached object if the cache has not invalidated. Otherwise,
#'   return \code{s3mpi::not_cached}.
fetch_from_cache <- function(key, cache_dir) {
  ## We use an [MD5 hash](https://en.wikipedia.org/wiki/MD5) to convert an
  ## arbitrary R object to a 32-character string representation. We use this
  ## as an implicit hash table in the file system so we do not have to deal
  ## with keys that cause conflicts with the file system (such as "../blah").
  cache_key <- digest::digest(key)
  cache_file <- function(dir) file.path(cache_dir, dir, cache_key)

  if (!file.exists(cache_file("data"))) return(not_cached)

  if (!file.exists(cache_file("info"))) {
    # Somehow the cache became corrupt: data exists without accompanying
    # meta-data. In this case, simply wipe the cache.
    file.remove(cache_file("data"))
    return(not_cached)
  }

  info <- readRDS(cache_file("info"))
  # Check if cache is invalid.
  connected <- has_internet()
  if (!connected) {
    warning("Your network connection seems to be unavailable. s3mpi will ",
            "use the latest cache entries instead of pulling from S3.",
            call. = FALSE, immediate. = FALSE)
  }

  ## If the modification time has changed since we last cached the
  ## value, re-pull it from S3 and wipe the cache.
  if (connected && !identical(info$mtime, last_modified(key))) {
    not_cached
  } else {
    readRDS(cache_file("data"))
  }
}

#' Helper function for saving a file to a cache directory.
#'
#' @param key character. The key under which the cache entry is stored.
#' @param value ANY. The R object to save in the cache.
#' @param cache_dir character. The cache directory. The default is
#'    \code{cache_directory()}.
save_to_cache <- function(key, value, cache_dir = cache_directory()) {
  cache_key  <- digest::digest(key)
  cache_file <- function(dir) file.path(cache_dir, dir, cache_key)

  saveRDS(value, cache_file("data"))
  info <- list(mtime = last_modified(key), key = key)
  saveRDS(info, cache_file("info"))
  invisible(NULL)
}

#' Determine the last modified time of an S3 object.
#'
#' @param key character. The s3 key of the object.
#' @return the last modified time or \code{NULL} if it does not exist on S3.
last_modified <- function(key) {
  ## If the user doesn't have internet, assume the file hasn't changed
  ## since we can't figure out if it has! Here, we simply pull from
  ## the cache.
  if (!has_internet()) { return(as.POSIXct(as.Date("2000-01-01"))) }
  s3result <- system2(s3cmd(), c("ls", key), stdout = TRUE)[1L]
  if (is.character(s3result) && !is.na(s3result) && nzchar(s3result)) {
    ## We use [`strptime`](https://stat.ethz.ch/R-manual/R-patched/library/base/html/strptime.html)
    ## to extract the modification time from the `s3cmd ls` query.
    strptime(substring(s3result, 1, 16), "%Y-%m-%d %H:%M")
  }
}

## This is a special object we use to signify the object is not
## cached. We assume no one will try to `s3store` an object with
## class `"not_cached"`!
not_cached <- local({ tmp <- list(); class(tmp) <- "not_cached"; tmp })
is.not_cached <- function(x) identical(x, not_cached)
