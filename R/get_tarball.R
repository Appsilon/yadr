#' Download package tarball from CRAN
#' @param package character(1)
#' @param version character(1)
#' @param path character(1)
#' @importFrom utils contrib.url download.file untar
#' @export
get_tarball <- function(package, version, path) {
  base_url <- contrib.url(repos = getOption("repos"))
  tarball_path <- paste(package, "_", version, ".tar.gz", sep = "")

  url_current <- file.path(base_url, tarball_path)
  url_archive <- file.path(base_url, "Archive", package, tarball_path)

  tryCatch(
    expr = {
      suppressWarnings(utils::download.file(url_archive, path, quiet = TRUE))
    },
    error = function(e) {
      suppressWarnings(utils::download.file(url_current, path, quiet = TRUE))
    }
  )
}
