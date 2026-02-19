test_that("get_versions", {
  package <- "rlang"
  cache <- list(
    rlang = data.frame(
      package = "rlang",
      version = "1.0.1",
      date = "2022-02-03"
    )
  )

  versions <- get_versions(package, cache = cache)
  testthat::expect_s3_class(versions, "data.frame")
  testthat::expect_gt(NROW(versions), 0)
})
