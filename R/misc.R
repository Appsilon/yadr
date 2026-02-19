# get_recursive_dependencies <- function(package, version) {
#   description <- get_package_description(package, version)
#   direct_dependencies <- get_direct_dependencies(description)
#   direct_dependencies <- get_versions(description, direct_dependencies)

#   sub_dependencies <- list()
#   for (i in 1:NROW(direct_dependencies)) {
#     ith_package <- direct_dependencies[i, "package"]
#     ith_version <- direct_dependencies[i, "version"]

#     ith_description <- get_package_description(ith_package, ith_version)
#     ith_dependencies <- get_direct_dependencies(
#       ith_description,
#       types = c("Depends", "Imports")
#     )
#     ith_versions <- get_package_versions(ith_package)
#   }
# }
