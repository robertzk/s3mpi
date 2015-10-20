## A standard helper: if `x` is null, `y` will be returned instead.
`%||%` <- function(x, y) if (is.null(x)) y else x

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
    if (is.mac() && system2("which", "brew", stdout = FALSE)) {
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

## A sexy [least recently used cache](http://mcicpc.cs.atu.edu/archives/2012/mcpc2012/lru/lru.html)
## using [the cacher package](https://github.com/kirillseva/cacher).
s3LRUcache <- cacher::LRUcache(getOption("s3mpi.cache_size", 10))

cache_enabled <- function() {
  !is.null(tmp <- cache_directory()) && nzchar(tmp)
}

cache_directory <- function() {
  dir <- getOption('s3mpi.cache')
  if (!is.null(dir) && !(is.character(dir) && length(dir) == 1 && !is.na(dir))) {
    stop("Please set the ", sQuote("s3mpi.cache"), " to a character ",
         "vector of length 1 giving a directory path.")
  }
  dir
}

has_internet <- local({
  has_internet_flag <- NULL
  function() {
    if (!is.null(getOption('s3mpi.skip_connection_check'))) return(FALSE)
    if (!is.null(has_internet_flag)) { return(has_internet_flag) }
    has_internet_flag <<- suppressWarnings({
      internet_check <- try(file('http://google.com', 'r'))
      if (!is(internet_check, 'try-error') && is(internet_check, 'connection')) {
        on.exit(close.connection(internet_check))
      }
      !(is(internet_check, 'try-error') &&
        grepl('cannot open', internet_check$message))
    })
  }
})

