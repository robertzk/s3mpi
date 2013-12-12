s3path <- function() {
  # Hardcode for R conference
  if (is.null(path <- getOption('s3mpi.path'))) path <- 's3://rconference/mpi'
  path
}
