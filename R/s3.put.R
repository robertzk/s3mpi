# Overwrite AWS.tools::s3.put because we would like to check md5.
s3.put <- function (x, bucket) {
    AWS.tools:::check.bucket(bucket)
    x.serialized <- tempfile()
    saveRDS(x, x.serialized)
    s3.cmd <- paste0("aws s3 cp ", x.serialized, " ", bucket)
    res <- system(s3.cmd, intern = TRUE)
    unlink(x.serialized)
    res
}
