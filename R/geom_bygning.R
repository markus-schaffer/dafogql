#' Query GEODKV Bygning geometry via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param building_id   Character vector of one or more building ids - building_id (BBRUUID)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to \code{c("geometri \{crs wkt\}", "BBRUUID")}.
#'                      Must be valid field names for the GEODKV_Bygning type.
#' @param node_names    Optional named character vector mapping API field names to output
#'                      column names, e.g. \code{c(BBRUUID = "building_id")}. Fields not
#'                      present in the mapping are returned with their original API name.
#'                      Defaults to \code{c(geometri.crs = "geom_crs", geometri.wkt =
#'                      "geom_wkt", BBRUUID = "building_id")}. Pass \code{NULL} to skip
#'                      renaming entirely.
#' @param batch_size    Maximum number of IDs per request (default: 100). More than 100
#'                      will be rejected by the API.
#'
#' @return A data frame with columns as specified by \code{nodes}, renamed according to
#'         \code{node_names} where a mapping exists
#'
#' @examples
#' \dontrun{
#' result <- geom_bygning(
#'   client_id     = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time          = "2026-03-16T00:00:00Z",
#'   building_id   = "00000000-1822-4d89-8bd8-c8eca3065c5f"
#' )
#' }
#' @export
geom_bygning <- function(
    client_id,
    client_secret,
    time,
    building_id,
    nodes = c(
      "geometri {crs wkt}",
      "BBRUUID"
    ),
    node_names = c(
      "geometri.crs" = "geom_crs",
      "geometri.wkt" = "geom_wkt",
      "BBRUUID"      = "building_id"
    ),
    batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = building_id,
    api_path = "geodkv/v2",
    query_var_type = "DafDateTime",
    filter_type = "GEODKV_BygningFilterInput",
    gql_var = "virkningstid",
    resource_name = "GEODKV_Bygning",
    where_builder = function(ids) list(BBRUUID = list(`in` = ids)),
    nodes = nodes, node_names = node_names, batch_size = batch_size
  )
}
