s3path <- function() {
  if(is.null(path <- getOption('s3mpi.path'))) {
    stop("Please set your s3 path using ",
         "options(s3mpi.path = 's3://your_bucket/your/path/'). ",
         "This is where all of your uploaded R objects will be stored.")
  }
  path
}
