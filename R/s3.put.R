# Overwrite AWS.tools::s3.put because we would like to check md5.
function (x, bucket, bucket.location = "US", verbose = FALSE,
    debug = FALSE, encrypt = FALSE) {
    check.bucket(bucket)
    x.serialized <- tempfile()
    saveRDS(x, x.serialized)
    s3.cmd <- paste("s3cmd put", x.serialized, bucket, ifelse(encrypt,
        "--encrypt", ""), paste("--bucket-location", bucket.location),
        "--no-progress", ifelse(verbose, "--verbose", ""), ifelse(debug,
            "--debug", ""), '--check-md5')
    res <- system(s3.cmd, intern = TRUE)
    unlink(x.serialized)
    res
}
