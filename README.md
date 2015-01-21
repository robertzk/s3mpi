S3 MPI [![Build Status](https://travis-ci.org/robertzk/s3mpi.svg?branch=master)](https://travis-ci.org/robertzk/s3mpi.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/robertzk/s3mpi/badge.png)](https://coveralls.io/r/robertzk/s3mpi)
=====

R message passing interface using S3 storage.

You can enable local caching of downloaded and uploaded files using:

```R
options(s3mpi.cache = '~/.s3cache') # Or a directory of your choice
```

If you have the caching layer enabled in the above manner, the s3mpi package will
check if you have a functioning connection to S3 before reading from the cache
to determine whether the value is invalidated (i.e., if someone updated the object).
If you wish to skip this check and read directly from the cache when you do not
have an internet connection, set `options(s3mpi.skip_connection_check = TRUE)`.

[![Build Status](https://travis-ci.org/robertzk/s3mpi.svg?branch=master)](https://travis-ci.org/robertzk/s3mpi.svg?branch=master)
