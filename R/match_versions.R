#' For each package dependency assign the latest version
#' that was avaiable before package release
#' @param description desc::desc
#' @param deps data.frame(type, package, version)
#' @param cache mutable env
#' @importFrom stringr str_sub
match_versions <- function(description, deps, cache = .versions_index) {
  release_date <- description$get_field("Date/Publication") |>
    stringr::str_sub(1, 10) |>
    as.Date()

  dep_versions <- c()

  for (pkg in deps$package) {
    versions <- get_versions(pkg, cache = cache)
    versions <- versions[versions$date <= release_date, ]
    dep_versions <- c(
      dep_versions,
      versions[versions$date == max(versions$date), "version"]
    )
  }

  deps$version <- dep_versions
  deps
}
