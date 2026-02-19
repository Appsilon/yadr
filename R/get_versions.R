#' Get a list of package versions
#' TODO: work beyond r-project's mirror of CRAN
#' TODO: work beyond CRAN
#' @param package character(1)
#' @param index mutable env
#' @importFrom utils strcapture contrib.url
#' @importFrom rvest read_html html_elements html_attr html_text
#' @export
get_versions <- function(package, index = .versions_index) {
  if (!is.null(index[[package]])) {
    return(index[[package]])
  }

  base_url <- utils::contrib.url(repos = getOption("repos"))

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
      data.frame(
        package = character(),
        version = character(),
        date = character()
      )
    }
  )

  releases <- rbind(archive_releases, latest_release)
  releases$date <- as.Date(releases$date)

  index[[package]] <- releases

  releases
}
