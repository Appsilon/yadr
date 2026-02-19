#' Download package tarball and parse the DESCRIPTION
#' @param package character(1)
#' @param version character(1)
#' @param index mutable env
#' @importFrom desc desc
#' @importFrom utils contrib.url download.file untar
#' @export
get_description <- function(package, version, index = .description_index) {
  if (!is.null(index[[package]])) {
    if (!is.null(index[[package]][[version]])) {
      return(index[[package]][[version]])
    }
  }

  base_url <- contrib.url(repos = getOption("repos"))

  if (length(base_url) > 1) {
    stop("Multiple repos not implemented")
  }

  tarball_path <- paste(package, "_", version, ".tar.gz", sep = "")

  url_current <- file.path(base_url, tarball_path)
  url_archive <- file.path(base_url, "Archive", package, tarball_path)

  path <- tempfile()

  tryCatch(
    expr = {
      suppressWarnings(utils::download.file(url_current, path, quiet = TRUE))
    },
    error = function(e) {
      suppressWarnings(utils::download.file(url_archive, path, quiet = TRUE))
    }
  )

  dir <- tempdir()

  utils::untar(path, exdir = dir)

  description <- desc::desc(file = file.path(dir, package))

  if (is.null(index[[package]])) {
    index[[package]] <- list()
  }

  index[[package]][[version]] <- description

  description
}
