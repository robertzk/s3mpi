read <- function(name = NULL, .path = s3path()) { 
  if (is.null(name)) name <- grab_latest_file_in_s3_dir(.path)
  s3.get(paste(.path, name, sep = ''))
}
