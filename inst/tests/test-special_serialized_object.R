context('special serialized object')

test_that('it can read special serialized object', {
	options(s3mpi.path = 's3://avantminer/tmp/')

  stub(s3read, "s3.get") <- function(...) structure(class =	'special_serialized_object',
	                                                  list(deserialize = function(.) . + 1,
													                               object = 1))
  cached_value <- NULL
  stub(s3read, "s3cache") <- function(...) if (length(list(...)) == 1) not_cached else cached_value <<- ..2

  old_opts <- options(s3mpi.cache = tempdir())
  on.exit(options(old_opts))

  expect_identical(s3read('blah'), 2)
  expect_is(cached_value, 'special_serialized_object')
  expect_identical(deserialize(cached_value), 2)
})


