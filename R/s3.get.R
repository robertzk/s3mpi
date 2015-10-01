s3.get <- function (bucket, bucket.location = "US", verbose = FALSE, debug = FALSE) {
  AWS.tools:::check.bucket(bucket)

  # Helper function for fetching data from s3
  fetch <- function(){
    x.serialized <- tempfile()
    s3.cmd <- paste("s3cmd get", bucket, x.serialized, paste("--bucket-location",
    bucket.location), ifelse(verbose, "--verbose --progress",
    "--no-progress"), ifelse(debug, "--debug", ""))
    system(s3.cmd)

    ans <- readRDS(x.serialized)
    unlink(x.serialized)
    ans
  }

  # Check for the bucket in the cache
  # If it does not exist, create and return its entry
  if (!s3cache$exists(bucket)) {
    ans <- fetch()
    s3cache$set(bucket, ans)
  } else{
    # Check time on s3cache's copy
    last_cached <- s3cache$last_accessed(bucket) # assumes a POSIXct object

    # Check time on s3 remote's copy
    s3.cmd <- paste("s3cmd ls ", bucket, "| awk '{print $1" "$2}' ")
    last_updated <- as.POSIXct(system(s3.cmd, intern = TRUE), tz="GMT")

    # Update the cache if remote is newer
    if (last_updated > last_cached) {
      ans <- fetch()
      s3cache$set(bucket, ans)
    } else {
      ans <- s3cache$get(bucket)
    }
  }
  ans
}
