test_that("match_versions", {
  package <- "rlang"
  version <- "1.0.1"

  description <- get_description(package, version)
  dependencies <- get_dependencies(description)
  versions <- get_versions(package)

  result <- match_versions(description, dependencies)
  testthat::expect_s3_class(result, "data.frame")
})
