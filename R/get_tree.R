#' Get a complete tree of dependencies for a package.
#' We are interested in hard+soft dependencies of the package itself,
#' as well as hard dependencies of all its direct dependencies.
#' @param package character(1)
#' @param version character(1)
#' @param description_cache mutable env
#' @param versions_cache mutable env
get_tree <- function(
  package,
  version,
  description_cache = .description_index,
  versions_cache = .versions_index
) {
  main_description <- get_description(
    package,
    version,
    cache = description_cache
  )
  direct_dependencies <- get_dependencies(main_description)
  direct_dependencies <- match_versions(main_description, direct_dependencies)

  sub_dependencies <- apply(direct_dependencies, 1, function(dep) {
    dep <- as.list(dep)
    sub_description <- get_description(
      dep$package,
      dep$version,
      cache = description_cache
    )

    dependencies <- get_dependencies(
      sub_description,
      types = c("Depends", "Imports")
    )

    match_versions(main_description, dependencies, cache = versions_cache)
  })

  sub_dependencies <- do.call(rbind, sub_dependencies)

  direct_dependencies$depth <- "direct"
  sub_dependencies$depth <- "recursive"

  all <- unique(rbind(direct_dependencies, sub_dependencies))

  all <- all[!duplicated(all[, c("package", "version")]), ]

  all
}
