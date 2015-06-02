# Version 0.2.8

 * A hotfix for cache corruption, where data exists without metadata.
   It can happen if writing metadata ever fails.

# Version 0.2.7

 * Remove the `s3mpi.memoize_cache` global option, since it makes no sense.
   A user could have overwritten an S3 key in a different R session.

 * `s3exists(NULL)` now returns FALSE.  Fixes issue #22.

# Version 0.2.5-6

 * The `s3mpi.memoize_cache` global controls whether or not caching is 
   [memoised](https://github.com/hadley/memoise). If set to `TRUE`, it would
   have the effect of keeping a common object in the R session instead of
   retrieving it from the cached file for each given s3 key. This can significantly
   speed up code that reads from the same S3 key multiple times within a 
   single R session.

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

