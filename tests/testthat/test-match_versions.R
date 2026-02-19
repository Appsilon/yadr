test_that("match_versions", {
  package <- "yadr"
  version <- "0.0.1"

  description_cache <- list(yadr = list("0.0.1" = desc::description$new()))
  versions_cache <- list(
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

  description <- get_description(package, version, cache = description_cache)
  dependencies <- get_dependencies(description)
  versions <- get_versions(package, cache = versions_cache)

  result <- match_versions(description, dependencies, cache = versions_cache)
  testthat::expect_s3_class(result, "data.frame")
})
