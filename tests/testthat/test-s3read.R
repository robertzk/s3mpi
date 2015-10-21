context("s3read")
library(testthatsomemore)

test_that("it can fetch raw values if the caching layer is disabled", {
  map <- list2env(list(key = "value"))
  testthatsomemore::package_stub("s3mpi", "s3read", function(...) map[[..1]], {
    expect_equal(s3read("key"), "value")
    map$key <- "new_value"
    # Make sure we are not caching.
    expect_equal(s3read("key"), "new_value")
  })
})
