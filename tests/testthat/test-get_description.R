test_that("get_description", {
  package <- "rlang"
  version <- "1.0.1"
  description <- get_description(package, version)

  testthat::expect_s3_class(description, "description")
})
