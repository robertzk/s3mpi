context("s3.get")
library(testthatsomemore)

test_that("it ignores bucket location flag if using s4cmd", {
  with_mock(s3cmd = function() "/usr/bin/s3cmd", {
    expect_equal(bucket_location_to_flag("US"), "--bucket-location US")
    expect_equal(bucket_location_to_flag("UK"), "--bucket-location UK")
  })

  with_mock(s3cmd = function() "/usr/bin/s4cmd", {
    expect_equal(bucket_location_to_flag("US"), "")
    expect_warning(bucket_location_to_flag("UK"), "Ignoring non-default bucket location")
    expect_equal(suppressWarnings(bucket_location_to_flag("UK")), "")
  })
})

#testthatsomemore::package_stub("AWS.tools", "check.bucket", function(...) { },  {
testthatsomemore::package_stub("base", "system", function(...) {
  if (grepl("s3cmd get", ..1)) {
    saveRDS("test", strsplit(" ", ..1)[[1]][4])
  } else {
    readRDS("test", strsplit(" ", ..1)[[1]][3])
  }
},  {
  test_that("it can get an object", {
    
  })
})
#})

