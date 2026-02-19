testthat::test_that("make_refs", {
  tree <- data.frame(
    package = c("rlang", "testthat"),
    version = c("1.0.1", "3.1.2")
  )

  refs <- make_refs(tree)

  testthat::expect_equal(
    refs,
    c(
      "cran::rlang@1.0.1?source",
      "cran::testthat@3.1.2?source"
    )
  )
})
