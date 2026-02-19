test_that("get_versions works for a normal package", {
  package <- "rlang"

  versions <- get_versions(package)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 0)
})

test_that("get_versions works with packages that only have latest version", {
  package <- "praise"
  versions <- get_versions(package)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 0)
})
