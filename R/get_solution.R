#' Get a complete tree of dependencies for a package.
#' We are interested in hard+soft dependencies of the package itself,
#' as well as hard dependencies of all its direct dependencies.
#' @param package character(1)
#' @param version character(1)
#' @param description_index mutable env
#' @param versions_index mutable env
#' @param recursive_resolution_limit integer(1)
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
#' @export
get_solution <- function(
  package,
  version,
  description_index = .description_index,
  versions_index = .versions_index,
  recursive_resolution_limit = 1000L
) {
  main_description <- get_description(
    package,
    version,
    index = description_index
  )
  direct_dependencies <- get_dependencies(main_description)
  direct_dependencies <- match_versions(main_description, direct_dependencies)

  resolution_queue <- direct_dependencies
  recursive_dependencies <- list()

  current_recursion_depth <- 0

  cli::cli_progress_bar(
    format = paste0(
      "{cli::pb_spin} Resolving {.pkg {cli::pb_extra$package}} ",
      "[{cli::pb_current} resolved | {cli::pb_extra$queued} queued] ",
      "{cli::pb_elapsed}"
    ),
    total = NA,
    extra = list(package = "", queued = NROW(resolution_queue))
  )

  while (NROW(resolution_queue) > 0) {
    current_recursion_depth <- current_recursion_depth + 1

    if (current_recursion_depth > recursive_resolution_limit) {
      stop("Dependency resolution reached recursive limit")
    }

    dep <- as.list(resolution_queue[1, ])
    resolution_queue <- resolution_queue[-1, ]

    cli::cli_progress_update(
      extra = list(
        package = paste(dep$package, dep$version, sep = "@"),
        queued = NROW(resolution_queue)
      )
    )

    sub_description <- get_description(
      dep$package,
      dep$version,
      index = description_index
    )

    deps <- get_dependencies(
      sub_description,
      types = c("Depends", "Imports")
    )

    deps <- match_versions(main_description, deps, index = versions_index)

    recursive_dependencies[[paste(dep$package, dep$version, sep = "@")]] <- deps
    resolution_queue <- rbind(resolution_queue, deps)
  }

  cli::cli_progress_done()

  recursive_dependencies <- do.call(rbind, recursive_dependencies)

  direct_dependencies$depth <- "direct"
  recursive_dependencies$depth <- "recursive"

  all <- unique(rbind(direct_dependencies, recursive_dependencies))

  all <- all[!duplicated(all[, c("package", "version")]), ]

  rownames(all) <- NULL

  all
}
