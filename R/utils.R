`%||%` <- function(x, y) if (is.null(x)) y else x

cache_enabled <- function() !is.null(tmp <- cache_directory()) && nzchar(tmp)
cache_directory <- function() getOption('s3mpi.cache')

has_internet <- local({
  has_internet_flag <- NULL
  function() {
    if (!is.null(getOption('s3mpi.skip_connection_check'))) return(FALSE)
    if (!is.null(has_internet_flag)) { return(has_internet_flag) }
    has_internet_flag <<- suppressWarnings({
      internet_check <- try(file('http://google.com', 'r'))
      if (!is(internet_check, 'try-error') && is(internet_check, 'connection')) {
        on.exit(close.connection(file))
      }
      !(is(internet_check, 'try-error') &&
        grepl('cannot open', internet_check$message))
    })
  }
})

