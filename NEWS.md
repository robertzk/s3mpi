# Version 0.2.2

 * Added a safety check for s3store. Now if you want to overwrite a key inside a bucket,
   you need to use s3store(key, safe = FALSE). By default safe is set to TRUE.
