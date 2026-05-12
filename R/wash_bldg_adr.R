#' Wash Building Addresses via Dataforsyningen Access Address Validation API
#'
#' Takes a character vector of addresses, deduplicates them, and validates each
#' against the Dataforsyningen access address (adgangsadresser) washing API.
#' Addresses classified as category "C" (no match) are dropped from the result.
#'
#' @param addresses A character vector of address strings to wash/validate.
#'
#' @return A data frame with columns:
#'   \item{address_wash}{The original address string as submitted to the API}
#'   \item{bldg_adr_id}{The matched access address UUID from DAR}
#'
#' @examples
#' \dontrun{
#' result <- wash_bldg_adr(c("Rådhuspladsen 1, 1550 København V"))
#' }
#' @export
wash_bldg_adr <- function(addresses) {
  wash_address(addresses,
    api_path       = "adgangsadresser",
    id_col_name    = "bldg_adr_id",
    progress_label = "wash buildings"
  )
}
