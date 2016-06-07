context("s3read")
library(testthatsomemore)

withr::with_options(list(
  s3mpi.path = "s3://test/",
  s3mpi.cache = NULL
), {
  describe("cache parameter validation", {
    with_mock(
      `s3mpi:::s3.get` = function(...) "value",
      `s3mpi:::s3cache` = function(...) TRUE, {
      test_that("if cache is not TRUE or FALSE, it errors", {
        expect_error(s3read("key", cache = "pizza", serialize = FALSE))
        expect_error(s3read("key", cache = 23, serialize = FALSE))
        expect_error(s3read("key", cache = iris, serialize = FALSE))
        expect_error(s3read("key", cache = NA, serialize = FALSE))
      })  
      test_that("if cache is TRUE, it does not error", {
        expect_equal(s3read("key", cache = TRUE, serialize = FALSE), "value")
      })
      test_that("if cache is FALSE, it does not error", {
        expect_equal(s3read("key", cache = FALSE, serialize = FALSE), "value")
      }) 
    }) 
  })

  test_that("if the path does not end in a slash, the slash is added", {
    map <- list2env(list("s3://path/key" = "value"))
    with_mock(
      `s3mpi:::s3.get` = function(...) map[[..1]], {
      expect_equal(s3read("key", path = "s3://path"), "value")
    }) 
  })

  test_that("it can fetch raw values if the caching layer is disabled", {
    map <- list2env(list("s3://test/key" = "value"))
    with_mock(`s3mpi:::s3.get` = function(...) map[[..1]], {
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

    with_mock(
      `s3mpi:::s3.get` = function(...) map[[..1]],
      `s3mpi:::s3cache` = function(...) "value", {
        expect_equal(s3read("key"), "value")
        map$`s3://test/key` <- "new_value"
        # Make sure we are caching.
        expect_equal(s3read("key"), "value")
    })
  })

  test_that("it can fetch unraw values if the caching layer is enabled but is uncached", {
    map <- list2env(list("s3://test/key" = "value"))
    cachedir <- tempdir()
    dir.create(cachedir, FALSE, TRUE)
    opts <- options(s3mpi.cache = cachedir)
    on.exit(options(opts), add = TRUE)

    with_mock(
      `s3mpi:::s3.get` = function(...) map[[..1]],
      `s3mpi:::s3cache` = function(...) not_cached, {
        expect_equal(s3read("key"), "value")
        map$`s3://test/key` <- "new_value"
        # Make sure we are not caching.
        expect_equal(s3read("key"), "new_value")
    })
  })
})

