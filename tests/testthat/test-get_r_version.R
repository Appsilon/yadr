testthat::test_that("get_r_versions", {
  versions <- get_r_versions()
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_named(versions, c("version", "date"))
  testthat::expect_contains(versions$version, "4.3.0")
})
