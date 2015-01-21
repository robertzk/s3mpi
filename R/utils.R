`%||%` <- function(x, y) if (is.null(x)) y else x

cache_enabled <- function() !is.null(tmp <- cache_directory()) && nzchar(tmp)
cache_directory <- function() getOption('s3mpi.cache')

has_internet <- function() {
  if (!is.null(getOption('s3mpi.skip_connection_check'))) return(FALSE)
  suppressWarnings({
    internet_check <- tryCatch(error = identity, file('http://google.com', 'r'))
    !(is(internet_check, 'error') &&
      grepl('cannot open', internet_check$message))
  })
}
