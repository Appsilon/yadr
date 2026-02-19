#' List of packages that shuold be ignored when fetching dependencies
.base_packages <- c("R", rownames(installed.packages(priority = "base")))

#' Shared index of package descriptions
.description_index <- readRDS(system.file(
  "descriptions.rds",
  package = "yadr",
  mustWork = TRUE
))

#' Shared index of package versions
.versions_index <- readRDS(system.file(
  "versions.rds",
  package = "yadr",
  mustWork = TRUE
))

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
