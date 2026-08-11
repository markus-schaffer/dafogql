#' Query BBR Etage via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param building_id   Character vector of building IDs (bygning_id)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to \code{c("bygning",
#'                      "eta022Kaelderareal", "eta023ArealAfLovligBeboelseIKaelder")}.
#'                      Must be valid field names for the BBR_Enhed type.
#' @param node_names    Optional named character vector mapping API field names to output
#'                      column names, e.g. \code{c(id_lokalId = "id")}. Fields not present
#'                      in the mapping are returned with their original API name. Pass
#'                      \code{NULL} to skip renaming entirely.
#' @param batch_size    Maximum number of IDs per request (default: 100). More than 100 will be rejected by the API.
#'
#' @return A data frame with columns as specified by \code{nodes}, renamed according to \code{node_names} where a mapping exists
#'
#' @examples
#' \dontrun{
#' result <- bbr_etage(
#'   client_id = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time = "2026-03-16T00:00:00Z",
#'   building_id = "0a3f50ca-201a-32b8-e044-0003ba298018"
#' )
#' }
#' @export
bbr_etage <- function(
    client_id,
    client_secret,
    time,
    building_id,
    nodes = c("bygning",
              "eta022Kaelderareal", 
              "eta023ArealAfLovligBeboelseIKaelder"),
    node_names = c(
      "eta022Kaelderareal" = "eta022_basement_area",
      "eta023ArealAfLovligBeboelseIKaelder" = "eta023_basement_area_living",
      "bygning" = "building_id"
    ),
    batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = building_id,
    api_path = "bbr/v2",
    query_var_type = "DafDateTime",
    filter_type = "BBR_EtageFilterInput",
    gql_var = "registreringstid",
    resource_name = "BBR_Etage",
    where_builder = function(ids) list(bygning = list(`in` = ids)),
    nodes = nodes, node_names = node_names, batch_size = batch_size
  )
}
