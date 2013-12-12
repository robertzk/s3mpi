s3store <- function(obj, name = NULL, .path = s3path()) {
  if (is.null(name)) name = deparse(substitute(obj))
  s3.put(obj, paste(.path, name, sep = ''))
}
  
