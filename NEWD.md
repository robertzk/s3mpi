# Version 0.2

 * Added a caching mechanism that will keep copies of files downloaded and
   uploaded to S3. Useful if local storage constraints are not an issue.
   To enable, set `options(s3mpi.cache = '~/.s3cache')` in your `~/.Rprofile`
   (or replace `'~/.s3cache'` with a directory of your choice).
