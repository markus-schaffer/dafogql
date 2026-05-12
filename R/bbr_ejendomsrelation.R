#' Query BBR Ejendomsrelation via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param bfe           Character vector of one or more BFEs (Bestemt Fast Ejendom)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to
#'                      \code{c("ejendommensEjerforholdskode", "bfeNummer")}.
#'                      Must be valid field names for the BBR_Ejendomsrelation type.
#' @param node_names    Optional named character vector mapping API field names to output
#'                      column names, e.g. \code{c(id_lokalId = "id")}. Fields not present
#'                      in the mapping are returned with their original API name. Defaults
#'                      to \code{c(ejendommensEjerforholdskode = "ownership_code",
#'                      bfeNummer = "bfe")}. Pass \code{NULL} to skip renaming entirely.
#' @param batch_size    Maximum number of IDs per request (default: 100). More than 100 will be rejected by the API.
#'
#' @return A data frame with columns as specified by \code{nodes}, renamed according to \code{node_names} where a mapping exists
#'
#' @examples
#' \dontrun{
#' result <- bbr_ejendomsrelation(
#'   client_id     = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time          = "2026-03-16T00:00:00Z",
#'   bfe           = "0a3f50ca-201a-32b8-e044-0003ba298018"
#' )
#' }
#' @export
bbr_ejendomsrelation <- function(
  client_id,
  client_secret,
  time,
  bfe,
  nodes = c("ejendommensEjerforholdskode", "bfeNummer"),
  node_names = c(ejendommensEjerforholdskode = "ownership_code", bfeNummer = "bfe"),
  batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = bfe,
    api_path = "bbr/v2",
    query_var_type = "DafDateTime",
    filter_type = "BBR_EjendomsrelationFilterInput",
    gql_var = "registreringstid",
    resource_name = "BBR_Ejendomsrelation",
    where_builder = function(ids) list(bfeNummer = list(`in` = ids)),
    nodes = nodes, node_names = node_names, batch_size = batch_size,
    id_prep = function(x) {
      x <- unique(x)
      x <- as.numeric(x)
      x[!is.na(x)]
    }
  )
}
