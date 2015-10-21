s3path <- function() {
  path <- getOption("s3mpi.path")

  if (is.null(path)) {
    stop("s3mpi package: Please set your s3 path using ",
         "options(s3mpi.path = 's3://your_bucket/your/path/'). ",
         "This is where all of your uploaded R objects will be stored.")
  }

  path
}
