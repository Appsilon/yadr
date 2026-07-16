#' Download package tarball and parse the DESCRIPTION
#' @param package character(1)
#' @param version character(1)
#' @param index mutable env
#' @importFrom desc desc
#' @export
get_description <- function(package, version, index = .description_index) {
  cached <- index[[package]][[version]]
  if (!is.null(cached)) {
    return(cached)
  }

  path <- tempfile()
  dir <- tempdir()

  get_tarball(package, version, path)

  utils::untar(path, exdir = dir)

  description <- desc::desc(file = file.path(dir, package))

  if (is.null(index[[package]])) {
    index[[package]] <- list()
  }

  index[[package]][[version]] <- description

  description
}
