#' A caching layer around s3mpi calls.
#'
#' Fetching large files from the S3 MPI can be expensive when performed
#' multiple times. This methods allows one to add a caching layer
#' around S3 fetching. The user should specify the configuration option
#' \code{options(s3mpi.cache = 'some/dir')}. The recommended cache
#' directory (where files will be stored) is \code{"~/.s3cache"}.
#'
#' @param s3key character. The full S3 key to attempt to read or write
#'    to the cache.
#' @param value ANY. The R object to save in the cache. If missing,
#'    a cache read will be performed instead.
s3cache <- function(s3key, value) {
  if (!cache_enabled())
    stop("Cannot use s3mpi::s3cache until you set options(s3mpi.cache) ",
         "to a directory in which to place cache contents.")

  dir.create(d <- cache_directory(), FALSE, TRUE)
  dir.create(file.path(d, 'info'), FALSE, TRUE)
  dir.create(file.path(d, 'data'), FALSE, TRUE)

  if (missing(value)) fetch_from_cache(s3key, d)
  else save_to_cache(s3key, value, d)
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
fetch_from_cache  <- function(key, cache_dir = cache_directory()) {
  require(digest)
  cache_key <- digest::digest(key)
  cache_file <- function(dir) file.path(cache_dir, dir, cache_key)

  if (!file.exists(cache_file('data'))) return(not_cached)

  info <- readRDS(cache_file('info'))
  # Check if cache is invalid.
  if (!has_internet())
    warning("Your network connection seems to be unavailable. s3mpi will ",
            "use the latest cache entries instead of pulling from S3.",
            call. = FALSE, immediate. = FALSE)
  else if (!identical(info$mtime, last_modified(key)))
    return(not_cached)

  readRDS(cache_file('data'))
}

#' Helper function for saving a file to a cache directory.
#'
#' @param key character. The key under which the cache entry is stored.
#' @param value ANY. The R object to save in the cache.
#' @param cache_dir character. The cache directory. The default is 
#'    \code{cache_directory()}.
save_to_cache <- function(key, value, cache_dir = cache_directory()) {
  require(digest)
  cache_key <- digest::digest(key)
  cache_file <- function(dir) file.path(cache_dir, dir, cache_key)

  saveRDS(value, cache_file('data'))
  info <- list(mtime = last_modified(key), key = key)
  saveRDS(info, cache_file('info'))
  invisible(NULL)
}

#' Determine the last modified time of an S3 object.
#'
#' @param key character. The s3 key of the object.
#' @return the last modified time or \code{NULL} if it does not exist on S3.
last_modified <- function(key) {
  s3result <- system(paste0('s3cmd ls ', key), intern = TRUE)[1]
  if (is.character(s3result) && !is.na(s3result) && nzchar(s3result))
    strptime(substring(s3result, 1, 16), '%Y-%m-%d %H:%M')
}

not_cached <- local({ tmp <- list(); class(tmp) <- 'not_cached'; tmp })
is.not_cached <- function(x) identical(x, not_cached)

