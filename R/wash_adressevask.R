#' Wash Addresses via the Adressevælger Vask API
#'
#' Takes a character vector of addresses, deduplicates them, and washes each
#' one against the Adressevælger \code{vask} API
#' (\url{https://adressevaelger.dk/vask/}). Addresses without a match are
#' dropped from the result.
#'
#' @param addresses A character vector of address strings to wash.
#' @param token API token for the Adressevælger service.
#'
#' @return A data frame with columns:
#'   \item{address_wash}{The address string as submitted to the API}
#'   \item{adr_id}{The matched address id (\code{adresse_id_lokalid}) from DAR}
#'   \item{adr_text}{The matched address designation (\code{adressebetegnelse})}
#'   \item{wash_code}{The wash status code (\code{vaskestatus$kode})}
#'   \item{wash_text}{The wash status text (\code{vaskestatus$tekst})}
#'
#' @examples
#' \dontrun{
#' result <- wash_adressevask(c("Sanct Keld Plads 11 2100 København Ø"))
#' }
#' @export
wash_adressevask <- function(addresses, token = "adressevaelger123") {
  un_adr <- unique(stats::na.omit(addresses))

  req <- httr2::request("https://adressevaelger.dk/vask/") |>
    httr2::req_url_query(token = token) |>
    httr2::req_throttle(capacity = 1000, fill_time_s = 5) |>
    httr2::req_retry(backoff = ~5, max_tries = 10)

  reqs <- lapply(un_adr, \(x) httr2::req_url_query(req, adresse = x))
  resps <- robust_perform(reqs, progress = "wash addresses")

  rows <- lapply(resps, \(x) {
    body <- httr2::resp_body_json(x, simplifyVector = FALSE)
    res <- body$vaskeresultat
    if (is.null(res$adresse_id_lokalid)) {
      return(NULL)
    }
    data.frame(
      address_wash = httr2::resp_url_query(x, "adresse")[[1]],
      adr_id       = res$adresse_id_lokalid,
      adr_text     = res$adressebetegnelse %||% NA_character_,
      wash_code    = body$vaskestatus$kode %||% NA_integer_,
      wash_text    = body$vaskestatus$tekst %||% NA_character_
    )
  })
  result <- do.call(rbind, rows)
  if (is.null(result)) {
    result <- data.frame(
      address_wash = character(), adr_id = character(), adr_text = character(),
      wash_code = integer(), wash_text = character()
    )
  }
  unique(result)
}

`%||%` <- function(x, y) if (is.null(x)) y else x
