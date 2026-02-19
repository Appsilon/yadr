test_that("get_description", {
  package <- "rlang"
  version <- "1.0.1"
  cache <- list(rlang = list("1.0.1" = desc::description$new()))

  description <- get_description(package, version, cache = cache)

  testthat::expect_s3_class(description, "description")
})
