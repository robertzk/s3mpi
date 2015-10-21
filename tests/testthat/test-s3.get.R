context("s3.get")
library(testthatsomemore)

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

