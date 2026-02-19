testthat::test_that("get_tree", {
  package <- "rlang"
  version <- "1.0.1"

  tree <- get_tree(package, version)

  testthat::expect_s3_class(tree, "data.frame")
  testthat::expect_equal(nrow(tree), 50)
  testthat::expect_equal(
    tree[tree$package == "testthat", "version"],
    "3.1.2"
  )
})
