context("s3.get")
library(testthatsomemore)

test_that("it ignores bucket location flag if using s4cmd", {
  expect_equal(bucket_location_to_flag("/usr/bin/s3cmd", "US"), "--bucket-location US");
  expect_equal(bucket_location_to_flag("/usr/bin/s3cmd", "UK"), "--bucket-location UK");
  expect_equal(bucket_location_to_flag("/usr/bin/s4cmd", "US"), "");
  expect_equal(bucket_location_to_flag("/usr/bin/s4cmd", "UK"), "");
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

