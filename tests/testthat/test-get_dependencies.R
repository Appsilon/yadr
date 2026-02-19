test_that("get_dependencies", {
  description <- desc::description$new()
  deps <- get_dependencies(description)
  testthat::expect_equal(
    deps$package,
    c("desc", "rvest", "testthat")
  )
})
