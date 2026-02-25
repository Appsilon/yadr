#' Get the list of R version/release date combinations
#' @importFrom utils contrib.url
#' @importFrom rvest read_html html_table
#' @export
get_r_versions <- function() {
  url <- utils::contrib.url(repos = getOption("repos"))

  html <- rvest::read_html(url)
  table <- rvest::html_table(html)[[1]]

  table <- table[grepl("^\\d+\\.\\d+\\.\\d+/$", table$Name), c(2, 3)]
  names(table) <- c("version", "date")

  table$version <- gsub("/$", "", table$version)
  table$date <- as.Date(substr(table$date, 1, 10))

  table
}
