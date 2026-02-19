#' Get a list of package versions
#' TODO: work beyond r-project's mirror of CRAN
#' TODO: work beyond CRAN
#' @param package character(1)
#' @param cache mutable env
#' @importFrom utils strcapture
#' @importFrom rvest read_html html_elements html_attr html_text
#' @export
get_versions <- function(package, cache = .versions_index) {
  if (!is.null(cache[[package]])) {
    return(cache[[package]])
  }

  base_url <- contrib.url(repos = getOption("repos"))

  latest_row <- rvest::read_html(base_url) |>
    rvest::html_element(sprintf("tr:has(a[href^='%s'])", package))
  latest_href <- latest_row |>
    rvest::html_element("a") |>
    rvest::html_attr("href")
  latest_release <- utils::strcapture(
    "(.*)_(.*)\\.tar\\.gz",
    latest_href,
    data.frame(package = character(), version = character())
  )
  latest_release$date <- latest_row |>
    rvest::html_element("td:has(a) + td") |>
    rvest::html_text() |>
    substr(1, 10)
  names(latest_release) <- c("package", "version", "date")

  archive_releases <- tryCatch(
    expr = {
      url <- file.path(base_url, "Archive", package)
      page <- rvest::read_html(url)

      archive_hrefs <- rvest::html_elements(page, "tr > td > a") |>
        rvest::html_attr("href")
      rels <- utils::strcapture(
        "(.*)_(.*)\\.tar\\.gz",
        archive_hrefs,
        data.frame(package = character(), version = character())
      )

      rels$date <- rvest::html_elements(
        page,
        "tr > td:has(a) + td"
      ) |>
        rvest::html_text() |>
        substr(1, 10)

      names(rels) <- c("package", "version", "date")
      rels[!is.na(rels$package), ]
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
