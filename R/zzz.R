#' List of packages that shuold be ignored when fetching dependencies
.base_packages <- c("R", rownames(installed.packages(priority = "base")))

#' Shared index of package descriptions that acts as a cache
.description_index <- new.env()

#' Shared index of package versions that acts as package-level cache
.versions_index <- new.env()

#' Run logic when package is loaded
#' @param libname builtin
#' @param pkgname builtin
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "YADR only supports official cran mirror. ",
    "Setting CRAN mirror to cran.r-project.org."
  )
  options(repos = "https://cran.r-project.org/")
}
