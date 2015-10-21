context("s3store")
library(testthatsomemore)

local({
  opts <- options(s3mpi.path = "s3://test/")
  on.exit(options(opts), add = TRUE)

  test_that("it can fetch raw values if the caching layer is disabled", {
    map <- list2env(list("s3://test/key" = "value"))
    testthatsomemore::package_stub("s3mpi", "s3.get", function(...) map[[..1]], {
      expect_equal(s3read("key", cache = FALSE), "value")
      map$`s3://test/key` <- "new_value"
      # Make sure we are not caching.
      expect_equal(s3read("key", cache = FALSE), "new_value")
    })
  })

  test_that("it can fetch unraw values if the caching layer is enabled", {
    map <- list2env(list("s3://test/key" = "value"))
    cachedir <- tempdir()
    dir.create(cachedir, FALSE, TRUE)
    opts <- options(s3mpi.cache = cachedir)
    on.exit(options(opts), add = TRUE)

    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3cache", function(...) "value", {
      expect_equal(s3read("key"), "value")
      map$`s3://test/key` <- "new_value"
      # Make sure we are caching.
      expect_equal(s3read("key"), "value")
    })})
  })

  test_that("it can fetch unraw values if the caching layer is enabled but is uncached", {
    map <- list2env(list("s3://test/key" = "value"))
    cachedir <- tempdir()
    dir.create(cachedir, FALSE, TRUE)
    opts <- options(s3mpi.cache = cachedir)
    on.exit(options(opts), add = TRUE)

    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3cache", function(...) not_cached, {
      expect_equal(s3read("key"), "value")
      map$`s3://test/key` <- "new_value"
      # Make sure we are not caching.
      expect_equal(s3read("key"), "new_value")
    })})
  })
})


