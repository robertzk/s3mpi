# Copied from https://github.com/rstudio/packrat/blob/master/R/platform.R
is.windows <- function() {
  Sys.info()["sysname"] == "Windows"
}

is.mac <- function() {
  Sys.info()["sysname"] == "Darwin"
}

is.linux <- function() {
  Sys.info()["sysname"] == "Linux"
}

