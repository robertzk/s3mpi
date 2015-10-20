S3 MPI [![Build Status](https://travis-ci.org/robertzk/s3mpi.svg?branch=master)](https://travis-ci.org/robertzk/s3mpi) [![Coverage Status](https://coveralls.io/repos/robertzk/s3mpi/badge.png)](https://coveralls.io/r/robertzk/s3mpi)
=====

R message passing interface using S3 storage.

You can store any R object to S3:

```R
s3mpi::s3store(obj, "s3key/for/your/object")
```

You can then read it back from S3 in any R session:

```R
s3mpi::s3read("s3key/for/your/object")
```


#### Installing the Package

```R
if (!require("devtools")) { install.packages("devtools") }
devtools::install_github("avantcredit/AWS.tools")
devtools::install_github("kirillseva/cacher")
devtools::install_github("robertzk/s3mpi")
```


#### Setting Up S3MPI

To get S3MPI to work, you first have to [set up an account on Amazon S3](https://aws.amazon.com/s3/) and get an S3 bucket.

After you have a bucket, add your Amazon keys to your `.bash_profile` / `.zshrc`:

```
export AWS_ACCESS_KEY_ID=PUTYOURACCESSKEYHERE
export AWS_SECRET_ACCESS_KEY=PUTYOURSECRETKEYHERE
```

Then add the following to your `~/.Rprofile`:

```R
options(s3mpi.path = "s3://yourS3Bucket/")
```


#### Local Caching

You can enable local caching of downloaded and uploaded files using:

```R
options(s3mpi.cache = '~/.s3cache') # Or a directory of your choice
```

If you have the caching layer enabled in the above manner, the s3mpi package will
check if you have a functioning connection to S3 before reading from the cache
to determine whether the value is invalidated (i.e., if someone updated the object).
If you wish to skip this check and read directly from the cache when you do not
have an internet connection, set `options(s3mpi.skip_connection_check = TRUE)`.


#### Ruby and Python Versions

You can also use S3MPI in [Ruby](https://github.com/robertzk/s3mpi-ruby) and in [Python](https://github.com/robertzk/s3mpy).

#### Command Line Accompaniment

One can find file size(z) and contents of the remote bucketusing the [s3 command line tool](http://s3tools.org/s3cmd)

```sh
s3cmd ls s3://yourS3Bucket/"
s3cmd ls -H  s3://yourS3Bucket/" # Human Readable
```
