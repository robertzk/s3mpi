if (!require(testthat)) {
  install.packages('testthat', repos='http://cran.us.r-project.org')
  require(testthat)
}
test_package("s3mpi")
