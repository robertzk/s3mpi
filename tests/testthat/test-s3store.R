context("s3store")
library(testthatsomemore)

withr::with_options(list(
  s3mpi.path = "s3://test/",
  s3mpi.cache = NULL
), {
  test_that("it stops if safe is enabled and we overwrite", {
    testthatsomemore::package_stub("s3mpi", "s3exists", function(...) TRUE, {
      expect_error(s3store("foo", "bar", safe = TRUE), "already exists")
    })
  })

  test_that("it can store raw values if the caching layer is disabled", {
    map <- list2env(list("s3://test/key" = NULL))
    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) map[[paste0(..2, ..3)]] <- ..1, {
      s3store("value", "key")
      expect_equal(s3read("key"), "value")
      map$`s3://test/key` <- "new_value"
      # Make sure we are not caching.
      expect_equal(s3read("key", cache = FALSE), "new_value")
    })})
  })

  test_that("it can store values if the caching layer is enabled", {
    map <- list2env(list("s3://test/key" = NULL))
    map2 <- new.env(parent = map)
    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map2[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) map2[[paste0(..2, ..3)]] <- ..1, {
      s3store("value", "key")
      expect_equal(s3read("key"), "value")
      map$`s3://test/key` <- "new_value"
      # Make sure we are not caching.
      expect_equal(s3read("key"), "value")
    })})
  })

  test_that("it denormalizes", {
    map <- list2env(list("s3://test/key" = "value"))

    testthatsomemore::package_stub("s3mpi", "s3normalize",  function(a, b) { map$norm <- missing(b); a }, {
    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) map[[paste0(..2, ..3)]] <- ..1, {
      s3store("value", "key")
      expect_false(map$norm)
      s3store(new.env(), "key2")
      expect_true(map$norm)
    })})})
  })

  test_that("it can pick up missing key", {
    map <- list2env(list("s3://test/key" = NULL))
    testthatsomemore::package_stub("s3mpi", "s3.get",  function(...) map[[..1]], {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) map[[paste0(..2, ..3)]] <- ..1, {
      key <- "value"
      s3store(key)
      expect_equal(s3read("key"), "value")
    })})
  })

  test_that("it produces an error when the object isn't found with an s3exists following the s3.put", {
    testthatsomemore::package_stub("base", "system2",  function(...) TRUE, {
    testthatsomemore::package_stub("s3mpi", "s3exists",  function(...) FALSE, {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) run_system_put(..2, ..3, "", TRUE, 0), {
      expect_error(s3store("value", "key"))
    })})})
  })

  test_that("it does not produce an error when the object is found with an s3exists following the s3.put", {
    testthatsomemore::package_stub("base", "system2",  function(...) TRUE, {
    testthatsomemore::package_stub("s3mpi", "s3exists",  function(...) TRUE, {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) run_system_put(..2, ..3, "", TRUE, 0), {
      expect_error(s3store("value", "key"), NA)
    })})})
  })

  calling_intervals <- NULL
  test_that("it can retry with the correct timing when an s3exists returns FALSE", {
    testthatsomemore::package_stub("base", "Sys.sleep",  function(...) calling_intervals <<- c(calling_intervals, ..1), {
    testthatsomemore::package_stub("base", "system2",  function(...) TRUE, {
    testthatsomemore::package_stub("s3mpi", "s3exists",  function(...) FALSE, {
    testthatsomemore::package_stub("s3mpi", "s3.put", function(...) run_system_put(..2, ..3, "", TRUE, 3, c(1, 2, 100)), {
      try(run_system_put(,, "", TRUE, 3, c(1, 2, 100)), silent = TRUE)
      expect_identical(calling_intervals, c(1, 2, 100))
    })})})})
  })
})


