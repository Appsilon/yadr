testthat::test_that("get_tree", {
  package <- "R6"
  version <- "2.6.0"

  tree <- get_solution(package, version)

  testthat::expect_s3_class(tree, "data.frame")
  testthat::expect_equal(nrow(tree), 26)
  testthat::expect_equal(
    tree[tree$package == "testthat", "version"],
    "3.2.3"
  )
})
