R and AWS S3 [![Build Status](https://travis-ci.org/robertzk/s3mpi.svg?branch=master)](https://travis-ci.org/robertzk/s3mpi) [![Coverage Status](https://coveralls.io/repos/robertzk/s3mpi/badge.png)](https://coveralls.io/r/robertzk/s3mpi) [![Documentation](https://img.shields.io/badge/rocco--docs-%E2%9C%93-blue.svg)](http://robertzk.github.io/s3mpi/)
=========

A common problem for data scientists is passing data or models to each
other without interrupting their workflow. There are typically two approaches:

  1. Writing CSV and RDS files and passing them around using tools like
     email, Dropbox, or SFTP. Typically, these files are too large for
     inclusion in version control.

  2. Building an API infrastructure around some data backends, such as
     databases, data warehouses, and streaming providers like Kafka.

The former works well for small teams consisting of 1-3 people but soon
becomes prohibitive. Additionally, tracking the array of files and outputs
soon becomes cumbersome and interrupts the data scientist's workflow.

The second option is an inevitable progression for any sufficiently large data
team, but requires major coordination with software or data engineers
and may not be practical for small teams or experimental projects. It is
also usually limited by well-defined specification of the formats that
are being passed into consoles and outputted to data storage systems.

On the other hand, S3mpi (S3 [*message passing interface*](https://en.wikipedia.org/wiki/Message_Passing_Interface),
affectionately named after the distributed message passing library) 
allows for **storage and serialization of arbitrary R objects** and does
not have the limits of the second approach, while providing **on-demand
access to stored data and objects**, avoiding the need for large amounts of
disk space locally.

Here, S3 stands for [Amazon's cloud storage](https://aws.amazon.com/s3/) which
you can think of as an infinite hard drive. You write an object to a path,
and then it *remains there indefinitely and is accessible to anyone you wish
to share it with*. For example, if you have several terabytes of datasets split
into thousands of components, you can individually load small pieces and perform
computation on them to avoid storing the entire dataset locally. This is the
basis for distributed computing systems like [Hadoop](https://en.wikipedia.org/wiki/Apache_Hadoop).

Assuming you have set up your [S3 configuration](http://s3tools.org/kb/item14.htm)
correctly (see the tutorial below), you can immediately get started with:

```R
library(s3mpi)
s3store(obj, "s3key/for/your/object")
```

You can then read it back from S3 in any R session running on a machine with
compatible S3 credentials:

```R
s3read("s3key/for/your/object")
```

Paired with [chat-driven development](https://sameroom.io/blog/self-hosted-team-chat-options-and-alternatives/)
this allows a team of data scientists to quickly generate team-global accessible
objects like data sets and models and chat the key to teammates so they pull down
the results within seconds for inspection, modification, or further analysis.

#### Installing the Package

This package is not currently available on CRAN and has several non-CRAN
dependencies. First, ensure you have the [s3cmd](http://s3tools.org/s3cmd) command-line
tool installed. If you are on OS X, you can simply run `brew install s3cmd` if
you have [homebrew](http://brew.sh/). Next, you will have to copy the [example
`.s3cfg`](http://s3tools.org/kb/item14.htm) file and place it in `~/.s3cfg` (or
generate it using `s3cmd --configure`) and then obtain
[AWS access credentials](http://docs.aws.amazon.com/general/latest/gr/getting-aws-sec-creds.html)
and fill out the `access_key` and `secret_key` sections of your `~/.s3cfg` file.
Note that [S3 storage is pretty cheap](https://aws.amazon.com/s3/pricing/)
and even the most intense data use is unlikely to exceed $100/month.

To install the R package and its dependencies, run the following from the R console.

```R
if (!require("devtools")) { install.packages("devtools") }
devtools::install_github("avantcredit/AWS.tools")
devtools::install_github("kirillseva/cacher")
devtools::install_github("robertzk/s3mpi")
```

This package has been used on OSX and Linux systems in a production-facing
environment, but **we have not tested it extensively on Windows**,
so if you run into problems please [file an issue](https://github.com/robertzk/s3mpi/issues/new)
immediately.

Finally, put the name of a default [bucket](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html)
in your `~/.Rprofile`:

```R
options(s3mpi.path = "s3://yourS3Bucket/")
```

If you do not specify a default S3 path, you will have to include it
manually as the second parameter:

```R
s3store(obj, "s3key/for/your/object", "s3://somebucket/")
# From another R session
s3read("s3key/for/your/object", "s3://somebucket/")
```

#### Potential uses

S3mpi has been used in production-facing environments for:

  1. Light-weight **mapreduce** for background jobs on medium data sets. One can
     partition a set of primary keys, perform a computation, and `s3store`
     the results in a separate S3 location for each partition.
  
  2. **Logging** supplementation. For example, if you alert your errors to
     a service like [honeybadger](http://honeybadger.io) it is possible to
     provide additional details by noting the S3 key with an R object containing
     further information in the notification. This also works with chat-driven
     development using [hipchat](http://hipchat.com) or [slack](http://slack.com)
     by adding an S3 key with "additional details" to failure notifications.

  3. **Caching** of functions that should have deterministic outputs or infrequent
     refresh intervals can be accomplishing by wrapping it with an
     ["s3 memoise"](https://github.com/peterhurford/s3memoize) layer (compare to
     the totally in-memory [memoise](https://github.com/hadley/memoise)).

  4. For **debugging**, it is possible to `s3store` intermediate output during a complex
     computation for later inspection, especially if you do not wish to store
     this information on the local file system.

  5. **Collaboration** in data science teams can be massively improved by
     using `s3store` and `s3read` to quickly pass data sets under investigation
     between R sessions. ("Hey can you send me the IDs of the customers that
     had a messed up leads record?") This completely eliminates the error-prone
     email / dropbox alternative and leaves a paper trail since it is unlikely
     one would ever need to delete objects from S3.

  6. Interfacing with **production environments** during background jobs, especially
     if a compatible [Ruby](https://github.com/robertzk/s3mpi-ruby) or
     [Python](https://github.com/robertzk/s3mpy) API is written. This can be used
     to ask an engineer to pull data from a production console, "ruby s3store"
     or "python s3store" it, and seamlessly read it from the R console as an
     R object such as a list or a data.frame. This **narrows the gap between
     analysts and engineers**.

  7. **Reproducible reports** can be generated by storing all intermediate and
     final output in a pre-defined S3 convention. At [Avant](https://github.com/avantcredit),
     this approach is used to store all information about all trained models
     stretching to the beginning of time.

The time required to store and read objects can be massively sped up by
adopting a workflow where one **sshes into an [EC2 instance](https://aws.amazon.com/ec2/instance-types/)**.

#### Alternative S3 key setup

Instead of setting up an `~/.s3cfg` file, you can also add the
following environment variables to `.bash_profile` / `.zshrc`:

```
export AWS_ACCESS_KEY_ID=PUTYOURACCESSKEYHERE
export AWS_SECRET_ACCESS_KEY=PUTYOURSECRETKEYHERE
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

One can find file size(s) and contents of the remote bucket 
using the [s3 command line tool](http://s3tools.org/s3cmd):

```sh
s3cmd ls s3://yourS3Bucket/some/key"
s3cmd ls -H  s3://yourS3Bucket/some/key" # Human readable
```

### License

This project is licensed under the MIT License:

Copyright (c) 2015-2016 Robert Krzyzanowski

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Authors

This package was originally created by Robert Krzyzanowski. Additional
maintenance and improvement work was later done by Peter Hurford
and Kirill Sevastyanenko.

