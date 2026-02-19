#' Get a list of package versions
#' TODO: get latest version
#' TODO: work beyond r-project's mirror of CRAN
#' TODO: work beyond CRAN
#' @param package character(1)
#' @param index mutable env
#' @importFrom rvest read_html,html_elements,html_attr,html_text
#' @importFrom stringr str_extract,str_sub
#' @export
get_versions <- function(package, cache = .versions_index) {
  if (!is.null(cache[[package]])) {
    cat("Cache hit: versions of", package, "\n")
    return(cache[[package]])
  }

  cat("Cache miss: versions of", package, "\n")

  url <- file.path(BASE_URL, "Archive", package)
  page <- rvest::read_html(url)

  releases <- rvest::html_elements(page, "tr > td > a") |>
    rvest::html_attr("href") |>
    stringr::str_extract("(.*)_(.*)\\.tar\\.gz", group = c(1, 2)) |>
    as.data.frame()

  releases$date <- rvest::html_elements(page, "tr > td:has(a) + td") |>
    rvest::html_text() |>
    stringr::str_sub(1, 10)

  names(releases) <- c("package", "version", "date")
  releases <- releases[!is.na(releases$package), ]
  releases$date <- as.Date(releases$date)

  cache[[package]] <- releases

  releases
}
