#' Query MAT Jordstykke via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param plot_id       Character vector of one or more plot IDs (Jordstykke)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to
#'                      \code{c("id_lokalId", "samletFastEjendomLokalId")}.
#'                      Must be valid field names for the MAT_Jordstykke type.
#' @param node_names    Optional named character vector mapping API field names to output
#'                      column names, e.g. \code{c(id_lokalId = "id")}. Fields not present
#'                      in the mapping are returned with their original API name. Defaults
#'                      to \code{c(id_lokalId = "plot_id", samletFastEjendomLokalId =
#'                      "sfe")}. Pass \code{NULL} to skip renaming entirely.
#' @param batch_size    Maximum number of IDs per request (default: 100). More than 100 will be rejected by the API.
#'
#' @return A data frame with columns as specified by \code{nodes}, renamed according to \code{node_names} where a mapping exists
#'
#' @examples
#' \dontrun{
#' result <- mat_jordstykke(
#'   client_id     = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time          = "2026-03-16T00:00:00Z",
#'   plot_id       = "0a3f50ca-201a-32b8-e044-0003ba298018"
#' )
#' }
#' @export
mat_jordstykke <- function(
  client_id,
  client_secret,
  time,
  plot_id,
  nodes = c("id_lokalId", "samletFastEjendomLokalId"),
  node_names = c(id_lokalId = "plot_id", samletFastEjendomLokalId = "sfe"),
  batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = plot_id,
    api_path = "mat/v2",
    query_var_type = "DafDateTime",
    filter_type = "MAT_JordstykkeFilterInput",
    gql_var = "registreringstid",
    resource_name = "MAT_Jordstykke",
    where_builder = function(ids) list(id_lokalId = list(`in` = ids)),
    nodes = nodes, node_names = node_names, batch_size = batch_size
  )
}
