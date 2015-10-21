#' Bi-directional communication with R and AWS S3.
#'
#' This package provides an interface to read and store arbitrary 
#' objects from and to Amazon AWS's S3 cloud storage.
#'
#' The exported helpers \code{s3read} and \code{s3store}
#' allow, upon correct configuration of your S3 credentials,
#' uploading to and downloading from S3 using R's built-in support
#' for serializing and deserializing arbitrary objects (see
#' \code{\link{readRDS}} and \code{\link{saveRDS}}).
#'
#' @name s3mpi
#' @docType package
#' @import AWS.tools crayon cacher digest stringr
NULL

## A sexy [least recently used cache](http://mcicpc.cs.atu.edu/archives/2012/mcpc2012/lru/lru.html)
## using [the cacher package](https://github.com/kirillseva/cacher).
s3LRUcache <- cacher::LRUcache(getOption("s3mpi.cache_size", 10))
