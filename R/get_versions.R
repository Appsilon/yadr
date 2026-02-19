#' Get a list of package versions
#' TODO: work beyond r-project's mirror of CRAN
#' TODO: work beyond CRAN
#' @param package character(1)
#' @param index mutable env
#' @importFrom rvest read_html html_elements html_attr html_text
#' @importFrom stringr str_extract str_sub
#' @export
get_versions <- function(package, cache = .versions_index) {
  if (!is.null(cache[[package]])) {
    cat("Cache hit: versions of", package, "\n")
    return(cache[[package]])
  }

  cat("Cache miss: versions of", package, "\n")

  base_url <- contrib.url(repos = getOption("repos"))

  latest_row <- rvest::read_html(base_url) |>
    rvest::html_element(sprintf("tr:has(a[href^='%s'])", package))
  latest_release <- latest_row |>
    rvest::html_element("a") |>
    rvest::html_attr("href") |>
    stringr::str_extract("(.*)_(.*)\\.tar\\.gz", group = c(1, 2)) |>
    matrix(ncol = 2) |>
    as.data.frame()
  latest_release$date <- latest_row |>
    rvest::html_element("td:has(a) + td") |>
    rvest::html_text() |>
    stringr::str_sub(1, 10)
  names(latest_release) <- c("package", "version", "date")

  archive_releases <- tryCatch(
    expr = {
      url <- file.path(base_url, "Archive", package)
      page <- rvest::read_html(url)

      rels <- rvest::html_elements(page, "tr > td > a") |>
        rvest::html_attr("href") |>
        stringr::str_extract("(.*)_(.*)\\.tar\\.gz", group = c(1, 2)) |>
        matrix(ncol = 2) |>
        as.data.frame()

      rels$date <- rvest::html_elements(
        page,
        "tr > td:has(a) + td"
      ) |>
        rvest::html_text() |>
        stringr::str_sub(1, 10)

      names(rels) <- c("package", "version", "date")
      rels[!is.na(releases$package), ]
    },
    error = function(e) {
      return
      data.frame(
        package = character(),
        version = character(),
        date = character()
      )
    }
  )

  releases <- rbind(archive_releases, latest_release)
  releases$date <- as.Date(releases$date)

  cache[[package]] <- releases

  releases
}
