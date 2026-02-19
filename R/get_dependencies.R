#' Extract package dependencies from its DESCRIPTION
#' @param description desc::desc
#' @param types character()
#' @export
get_dependencies <- function(
  description,
  types = c("Depends", "Imports", "Suggests")
) {
  deps <- description$get_deps()
  deps <- deps[deps$type %in% types, ]
  deps <- deps[!deps$package %in% .base_packages, ]

  deps
}
