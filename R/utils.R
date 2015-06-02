`%||%` <- function(x, y) if (is.null(x)) y else x

cache_enabled <- function() {
  !is.null(tmp <- cache_directory()) && nzchar(tmp)
}

cache_directory <- function() {
  dir <- getOption('s3mpi.cache')
  if (!is.null(dir) && !(is.character(dir) && length(dir) == 1 && !is.na(dir))) {
    stop("Please set the ", sQuote("s3mpi.cache"), " to a character ",
         "vector of length 1 giving a directory path.")
  }
  dir
}

has_internet <- local({
  has_internet_flag <- NULL
  function() {
    if (!is.null(getOption('s3mpi.skip_connection_check'))) return(FALSE)
    if (!is.null(has_internet_flag)) { return(has_internet_flag) }
    has_internet_flag <<- suppressWarnings({
      internet_check <- try(file('http://google.com', 'r'))
      if (!is(internet_check, 'try-error') && is(internet_check, 'connection')) {
        on.exit(close.connection(internet_check))
      }
      !(is(internet_check, 'try-error') &&
        grepl('cannot open', internet_check$message))
    })
  }
})

