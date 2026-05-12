#' Shared internal address washing helper
#'
#' Deduplicates addresses, validates each against the Dataforsyningen washing
#' API, and returns matched results (dropping category "C" non-matches).
#'
#' @param addresses      Character vector of address strings to wash/validate
#' @param api_path       Dataforsyningen API path segment
#'                       (\code{"adgangsadresser"} or \code{"adresser"})
#' @param id_col_name    Name of the ID column in the output data frame
#'                       (\code{"bldg_adr_id"} or \code{"unit_adr_id"})
#' @param progress_label Label shown in the progress bar during batched requests
#' @return A data frame with columns \code{address_wash} and the column named
#'         by \code{id_col_name}
#' @keywords internal
wash_address <- function(addresses, api_path, id_col_name, progress_label) {
  un_adr <- unique(addresses)

  req <- paste0("https://api.dataforsyningen.dk/datavask/", api_path, "?") |>
    httr2::request() |>
    httr2::req_throttle(capacity = 1000, fill_time_s = 5) |>
    httr2::req_retry(backoff = ~5, max_tries = 10)

  reqs <- lapply(un_adr, \(x) httr2::req_url_query(req, betegnelse = x))
  resps <- robust_perform(reqs, progress = progress_label)
  washer <- lapply(resps, \(x) httr2::resp_body_json(x, simplifyVector = TRUE))
  keep <- unlist(lapply(washer, \(x) x$kategori != "C"))

  result <- unique(data.frame(
    address_wash = vapply(resps[keep], \(x) httr2::resp_url_query(x, "betegnelse"), character(1)),
    id           = vapply(washer[keep], \(x) x$resultater$adresse$id, character(1))
  ))
  names(result)[names(result) == "id"] <- id_col_name
  result
}
