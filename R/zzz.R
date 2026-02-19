#' List of packages that shuold be ignored when fetching dependencies
.base_packages <- c("R", rownames(installed.packages(priority = "base")))

#' Shared index of package descriptions that acts as a cache:
#' i.e. package -> version -> DESCRIPTION.
#' e.g. .description_index[["rlang"]][["1.0.1"]] == desc::description$new()
.description_index <- new.env()

#' Shared index of package versions that acts as package-level cache:
#' i.e. package -> data.frame(package, version, date)
.versions_index <- new.env()

#' Run logic when package is loaded
.onLoad <- function(libname, pkgname) {
  message("YADR only supports official cran mirror.")
  message("Setting CRAN mirror to cran.r-project.org.")
  options(repos = "https://cran.r-project.org/")
}
