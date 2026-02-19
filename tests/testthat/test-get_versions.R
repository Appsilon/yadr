testthat::test_that("get_versions works for a normal package", {
  package <- "rlang"

  versions <- get_versions(package)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 1)
})

testthat::test_that("get_versions works for another normal package", {
  package <- "withr"

  versions <- get_versions(package)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 1)
})

testthat::test_that("get_versions works without archive", {
  package <- "praise"
  versions <- get_versions(package)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 0)
})
