#' Download package tarball and parse the DESCRIPTION
#' @param package character(1)
#' @param version character(1)
#' @param cache mutable env
#' @importFrom desc desc
#' @export
get_description <- function(package, version, cache = .description_index) {
  if (!is.null(cache[[package]])) {
    if (!is.null(cache[[package]][[version]])) {
      return(cache[[package]][[version]])
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
      print("Trying current url...")
      download.file(url_current, path, quiet = TRUE)
    },
    error = function(e) {
      print("Trying archive url...")
      download.file(url_archive, path, quiet = TRUE)
    }
  )

  dir <- tempdir()

  untar(path, exdir = dir)

  description <- desc::desc(file = file.path(dir, package))

  if (is.null(cache[[package]])) {
    cache[[package]] <- list()
  }

  cache[[package]][[version]] <- description

  description
}
