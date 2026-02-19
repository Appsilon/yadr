test_that("match_versions", {
  package <- "yadr"
  version <- "0.0.1"

  description_index <- list(yadr = list("0.0.1" = desc::description$new()))
  versions_index <- list(
    yadr = data.frame(
      package = "yadr",
      version = "0.0.1",
      date = "2026-02-19"
    ),
    desc = data.frame(
      package = "desc",
      version = "0.0.1",
      date = "2026-02-10"
    ),
    rvest = data.frame(
      package = "rvest",
      version = "0.0.1",
      date = "2026-02-10"
    ),
    stringr = data.frame(
      package = "stringr",
      version = "0.0.1",
      date = "2026-02-10"
    ),
    testthat = data.frame(
      package = "testthat",
      version = "0.0.1",
      date = "2026-02-10"
    )
  )

  description <- get_description(package, version, index = description_index)
  dependencies <- get_dependencies(description)
  versions <- get_versions(package, index = versions_index)

  result <- match_versions(description, dependencies, index = versions_index)
  testthat::expect_s3_class(result, "data.frame")
})
