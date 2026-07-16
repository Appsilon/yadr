#' For each package dependency assign the latest version
#' that was avaiable before package release
#' @param description desc::desc
#' @param deps data.frame(type, package, version)
#' @param index mutable env
match_versions <- function(description, deps, index = .versions_index) {
  release_date <- description$get_field("Date/Publication") |>
    substr(1, 10) |>
    as.Date()

  dep_versions <- c()

  cli::cli_progress_bar(
    format = paste0(
      "{cli::pb_spin} Matching versions {.pkg {cli::pb_extra$package}} ",
      "[{cli::pb_current}/{cli::pb_total}] {cli::pb_elapsed}"
    ),
    total = length(deps$package),
    extra = list(package = ""),
    clear = TRUE
  )

  for (pkg in deps$package) {
    cli::cli_progress_update(extra = list(package = pkg))
    versions <- get_versions(pkg, index = index)
    versions <- versions[versions$date <= release_date, ]
    dep_versions <- c(
      dep_versions,
      versions[versions$date == max(versions$date), "version"]
    )
  }

  cli::cli_progress_done()

  deps$version <- dep_versions
  deps
}
