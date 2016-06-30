# Version 0.2.31

* Make `s3store` work with s4cmd.

# Version 0.2.30

* Don't set --bucket-location flag if `s4cmd` is detected as the `s3cmd` binary.

# Version 0.2.29

* Revert the change in 0.2.21 in favor of using `s3cmd info` over
  `s3cmd ls` to obtain updated_at information on files.

# Version 0.2.28

* Add exponential backoff logic to s3.put function.

# Version 0.2.27
* Turn off the LRU cache too when `cache = FALSE` in `s3read`.

# Version 0.2.26
* `options(s3mpi.num_retries)` now allows you to specify default number of retries globally.

# Version 0.2.25
* Automatically adds ending slashes to paths if they are missing when using
  `s3store`, `s3exists`, or `s3delete`.

# Version 0.2.24

* Add the ability to delete an object in s3 using `s3delete`.

# Version 0.2.23

* `s3path()` is exported.

# Version 0.2.22

* `s3read()` (with no arguments) is no longer supported.

# Version 0.2.21

* Fixed an issue where reading files that have the same prefix as another file
  on the S3 bucket generates a warning.
* Fix a more serious problem where writing and reading within the same minute
  produces incorrect results due to the s3cmd utility having *minute*-level
  rather than second-level granularity.

# Version 0.2.20

* Workaround for the silent but oh-so-deadly sporadic failure of s3cmd's put.
  By default we now check for the existence of the object when issuing a put,
  with the option to retry a number of times.

# Version 0.2.19

* Keep AWS.tools on a remote.

# Version 0.2.18

* Add remotes to DESCRIPTION.

# Version 0.2.17

* Explicitly create the directory of a file given by `tempfile()` to prevent
  rare errors wherein the directory does not exist and yields a
  file connection error. ([#41](https://github.com/robertzk/s3mpi/issues/41))

# Version 0.2.16

* Introduce an `s3mpi.disable_lru_cache` option as well as
  silently fail if storage to LRU does not succeed.

# Version 0.2.15

* Switch to `system2`, which should be more windows friendly, and allow
  the user to specify path to executable of s3cmd, by setting `options(s3mpi.s3cmd_path = '/usr/local/bin/s3cmd')`

# Version 0.2.13

* Fixup LRU cache to actually use size parameter option.

# Version 0.2.11

* A stylistic refactor of the package. The `.path` argument
  has been deprecated in `s3read` and `s3store` in favor of
  simply `path`.

# Version 0.2.9-10

* Remove the need to type a trailing slash in `.path`.

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
