`%||%` <- function(x, y) if (is.null(x)) y else x

cache_enabled <- function() !is.null(tmp <- cache_directory()) && nzchar(tmp)
cache_directory <- function() getOption('s3mpi.cache')

has_internet <- function() {
  suppressWarnings({
    internet_check <- tryCatch(warning = identity, try_google <- file('http://google.com', 'r'))
    close(try_google)
    !(is(internet_check, 'warning') &&
      grepl('unable to resolve', internet_check$message))
  })
}
