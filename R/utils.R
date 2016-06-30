## A standard helper: if `x` is null, `y` will be returned instead.
`%||%` <- function(x, y) if (is.null(x)) y else x

## A package specific environment
.s3mpienv <- new.env()

## path to shell util
s3cmd <- function() {
  if (isTRUE(nzchar(cmd <- getOption("s3mpi.s3cmd_path")))) {
    cmd
  } else { as.character(Sys.which("s3cmd")) }
}

## Given an s3cmd path and a bucket location, will construct a flag
## argument for s3cmd.  If it looks like the s3cmd is actually
## pointing to an s4cmd, return empty string as s4cmd doesn't
## support bucket location.
bucket_location_to_flag <- function(bucket_location) {
  if (using_s4cmd()) {
    if (!identical(bucket_location, "US")) {
        warning(paste0("Ignoring non-default bucket location ('",
                       bucket_location,
                       "') in s3mpi::s3.get since s4cmd was detected",
                       "-- this might be a little slower but is safe to ignore."));
    }
    ""
  } else {
    paste("--bucket-location", bucket_location)
  }
}

## We use the [memoise](https://github.com/hadley/memoise) package to
## ensure this check only gets run once in a given R session. This
## means a user will have to restart R if they install s3cmd
## during a session, but we are comfortable with that!
ensure_s3cmd_present <- memoise::memoise(function() {
  check <- try(system("s3cmd --help", intern = TRUE), silent = TRUE)
  if (is(check, "try-error")) {
    ## It is always preferable to make life as easy as possible for the user!
    ## If they have the [homebrew](https://brew.sh) package manager, we
    ## give them the fastest installation instructions.
    if (is.mac() && system2("which", "brew", stdout = FALSE) == 0) {
      stop("Please install the ", crayon::yellow("s3cmd"), " command-line ",
           "utility using by running ", crayon::green("brew install s3cmd"),
           " from your terminal and then configuring your S3 credentials ",
           "using ", crayon::yellow("s3cmd --configure"), call. = FALSE)
    } else {
      ## Otherwise, manual it is!
      stop("Please install s3cmd, the S3 command line utility: ",
           "http://s3tools.org/kb/item14.htm\nand then setup your S3 ",
           "credentials using ", crayon::yellow("s3cmd --configure"),
           call. = FALSE)
    }
  }
})

cache_enabled <- function() {
  !is.null(tmp <- cache_directory()) && nzchar(tmp)
}

cache_directory <- function() {
  dir <- getOption("s3mpi.cache")
  if (!is.null(dir) && !(is.character(dir) && length(dir) == 1 && !is.na(dir))) {
    stop("Please set the ", sQuote("s3mpi.cache"), " option to a character ",
         "vector of length 1 giving a directory path.")
  }
  dir
}

## We ping google.com to ensure the user has an internet connection. If not,
## we operate in "offline mode" for the whole session, that is, we read
## from the s3cache if the user has set their `s3mpi.s3cache` option
## but cannot store or read new keys.
has_internet <- local({
  has_internet_flag <- NULL
  function() {
    if (!is.null(getOption("s3mpi.skip_connection_check"))) return(FALSE)
    if (!is.null(has_internet_flag)) { return(has_internet_flag) }
    has_internet_flag <<- suppressWarnings({
      internet_check <- try(file("http://google.com", "r"))
      if (!is(internet_check, "try-error") && is(internet_check, "connection")) {
        on.exit(close.connection(internet_check))
      }
      !(is(internet_check, "try-error") &&
        grepl("cannot open", internet_check$message))
    })
  }
})

## A sexy [least recently used cache](http://mcicpc.cs.atu.edu/archives/2012/mcpc2012/lru/lru.html)
## using [the cacher package](https://github.com/kirillseva/cacher).
s3LRUcache <- function() {
  if (is.null(.s3mpienv$lrucache)) {
    .s3mpienv$lrucache <- cacher::LRUcache(getOption("s3mpi.cache_size", "2Gb"))
  } else {
    .s3mpienv$lrucache
  }
}

# All S3 paths need a slash at the end to work, but we don't need the user
# to know that, so let's add a slash for them if they forget.
add_ending_slash <- function(path) {
  last_character <- function(str) {
    substr(str, nchar(str), nchar(str))
  }
  if (last_character(path) != "/") { paste0(path, "/") } else { path }
}

using_s4cmd <- function() {
  grepl("s4cmd", s3cmd())
}
