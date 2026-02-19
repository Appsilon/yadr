#' Shared index of package descriptions that acts as a cache:
#' i.e. package -> version -> DESCRIPTION.
#' e.g. .description_index[["rlang"]][["1.0.1"]] == desc::description$new()
.description_index <- new.env()

#' Shared index of package versions that acts as package-level cache:
#' i.e. package -> data.frame(package, version, date)
.versions_index <- new.env()
