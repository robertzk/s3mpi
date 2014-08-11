cache_enabled <- function() !is.null(tmp <- cache_directory()) && nzchar(tmp)
cache_directory <- function() getOption('s3mpi.cache')

has_internet <- function() {
  internet_check <- tryCatch(warning = identity, file('http://google.com', 'r'))
  !(is(internet_check, 'warning') &&
    grepl('unable to resolve', internet_check$message))
}
