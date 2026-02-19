#' Generate ref strings digestible by pak
#' @param dependency_tree data.frame(type, package, version, depth)
as_refs <- function(dependency_tree) {
  sprintf(
    "cran::%s@%s?source",
    dependency_tree$package,
    dependency_tree$version
  )
}
