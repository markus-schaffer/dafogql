#' Wash Unit Addresses via Dataforsyningen Address Validation API
#'
#' Takes a character vector of addresses, deduplicates them, and validates each
#' against the Dataforsyningen address washing API. Addresses classified as
#' category "C" (no match) are dropped from the result.
#'
#' @param addresses A character vector of address strings to wash/validate.
#'
#' @return A data frame with columns:
#'   \item{address_wash}{The original address string as submitted to the API}
#'   \item{unit_adr_id}{The matched address UUID from DAR}
#'
#' @examples
#' \dontrun{
#' result <- wash_unit_adr(c("Rådhuspladsen 1, 1550 København V"))
#' }
#' @export
wash_unit_adr <- function(addresses) {
  wash_address(addresses,
    api_path       = "adresser",
    id_col_name    = "unit_adr_id",
    progress_label = "wash units"
  )
}
