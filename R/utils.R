cache_enabled <- function() !is.null(tmp <- cache_directory()) && nzchar(tmp)
cache_directory <- function() getOption('s3mpi.cache')
