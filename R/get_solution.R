#' Get a complete tree of dependencies for a package.
#' We are interested in hard+soft dependencies of the package itself,
#' as well as hard dependencies of all its direct dependencies.
#' @param package character(1)
#' @param version character(1)
#' @param description_cache mutable env
#' @param versions_cache mutable env
#' @param recursive_resolution_limit integer(1)
get_solution <- function(
  package,
  version,
  description_cache = .description_index,
  versions_cache = .versions_index,
  recursive_resolution_limit = 1000L
) {
  main_description <- get_description(
    package,
    version,
    cache = description_cache
  )
  direct_dependencies <- get_dependencies(main_description)
  direct_dependencies <- match_versions(main_description, direct_dependencies)

  resolution_queue <- direct_dependencies
  recursive_dependencies <- list()

  current_recursion_depth <- 0

  while (NROW(resolution_queue) > 0) {
    current_recursion_depth <- current_recursion_depth + 1

    if (current_recursion_depth > recursive_resolution_limit) {
      stop("Dependency resolution reached recursive limit")
    }

    dep <- as.list(resolution_queue[1, ])
    resolution_queue <- resolution_queue[-1, ]

    sub_description <- get_description(
      dep$package,
      dep$version,
      cache = description_cache
    )

    deps <- get_dependencies(
      sub_description,
      types = c("Depends", "Imports")
    )

    deps <- match_versions(main_description, deps, cache = versions_cache)

    recursive_dependencies[[paste(dep$package, dep$version, sep = "@")]] <- deps
    resolution_queue <- rbind(resolution_queue, deps)
  }

  recursive_dependencies <- do.call(rbind, recursive_dependencies)

  direct_dependencies$depth <- "direct"
  recursive_dependencies$depth <- "recursive"

  all <- unique(rbind(direct_dependencies, recursive_dependencies))

  all <- all[!duplicated(all[, c("package", "version")]), ]

  rownames(all) <- NULL

  all
}
