# Version 0.2.4

 * The safety check on `s3store` uses `safe = FALSE` by default now. The new
   function `s3put` is equivalent to `s3store` and should be used going forward
   if one does not wish to overwrite existing keys. The other approach was causing
   too many breaking changes to existing codebases.

# Version 0.2.2

 * Added a safety check for `s3store`. Now if you want to overwrite a key inside a bucket,
   you need to use `s3store(key, safe = FALSE)`. By default safe is set to `TRUE`.

# Version 0.2.0

 * Added a caching mechanism that will keep copies of files downloaded and
   uploaded to S3. Useful if local storage constraints are not an issue.
   To enable, set `options(s3mpi.cache = '~/.s3cache')` in your `~/.Rprofile`
   (or replace `'~/.s3cache'` with a directory of your choice).

