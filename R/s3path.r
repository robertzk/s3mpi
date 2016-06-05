#' Get your default s3path or error.
#' @export
s3path <- function() {
  ## The default S3 prefix, for example, `s3://yourbucket/yourprefix/`.
  ## You should set this in everyone's `~/.Rprofile` if
  ## you are using s3mpi to collaborate in a data science team.
  path <- getOption("s3mpi.path")

  if (is.null(path)) {
    stop("s3mpi package: Please set your s3 path using ",
         "options(s3mpi.path = 's3://your_bucket/your/path/'). ",
         "This is where all of your uploaded R objects will be stored.")
  }

  path
}

