#' Query BBR Enhed via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param building_id       Character vector of building IDs (bygning_id)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to \code{c("adresseIdentificerer", "bygning",
#'                      "enh020EnhedensAnvendelse", "enh023Boligtype",
#'                      "enh026EnhedensSamledeAreal", "enh027ArealTilBeboelse",
#'                      "enh028ArealTilErhverv", "enh031AntalVaerelser",
#'                      "enh039AndetAreal", "enh045Udlejningsforhold",
#'                      "enh051Varmeinstallation", "enh052Opvarmningsmiddel",
#'                      "enh053SupplerendeVarme", "enh063AntalVaerelserTilErhverv",
#'                      "enh065AntalVandskylledeToiletter",
#'                      "enh066AntalBadevaerelser", "id_lokalId", "status")}.
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
#' result <- bbr_enhed(
#'   client_id = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time = "2026-03-16T00:00:00Z",
#'   building_id = "0a3f50ca-201a-32b8-e044-0003ba298018"
#' )
#' }
#' @export
bbr_enhed <- function(
  client_id,
  client_secret,
  time,
  building_id,
  nodes = c(
    "adresseIdentificerer",
    "bygning",
    "enh020EnhedensAnvendelse",
    "enh023Boligtype",
    "enh026EnhedensSamledeAreal",
    "enh027ArealTilBeboelse",
    "enh028ArealTilErhverv",
    "enh031AntalVaerelser",
    "enh039AndetAreal",
    "enh045Udlejningsforhold",
    "enh051Varmeinstallation",
    "enh052Opvarmningsmiddel",
    "enh053SupplerendeVarme",
    "enh063AntalVaerelserTilErhverv",
    "enh065AntalVandskylledeToiletter",
    "enh066AntalBadevaerelser",
    "id_lokalId",
    "status"
  ),
  node_names = c(
    "enh020EnhedensAnvendelse" = "enh020_unit_type_code",
    "enh023Boligtype" = "enh023_unit_housing_type_code",
    "enh026EnhedensSamledeAreal" = "enh026_unit_total_area",
    "enh027ArealTilBeboelse" = "enh027_unit_residential_area",
    "enh028ArealTilErhverv" = "enh028_unit_business_area",
    "enh031AntalVaerelser" = "enh031_unit_nr_room",
    "enh039AndetAreal" = "enh039_unit_other_area",
    "enh045Udlejningsforhold" = "enh045_unit_rent_status_code",
    "enh051Varmeinstallation" = "enh051_unit_heating_code",
    "enh052Opvarmningsmiddel" = "enh052_unit_heating_agent_code",
    "enh053SupplerendeVarme" = "enh053_unit_sup_heating_agent_code",
    "enh063AntalVaerelserTilErhverv" = "enh063_unit_nr_business_room",
    "enh065AntalVandskylledeToiletter" = "enh065_unit_nr_toilet",
    "enh066AntalBadevaerelser" = "enh066_unit_nr_bathroom",
    "status" = "status",
    "bygning" = "building_id",
    "adresseIdentificerer" = "unit_unit_adr_id",
    "id_lokalId" = "unit_id"
  ),
  batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = building_id,
    api_path = "bbr/v2",
    query_var_type = "DafDateTime",
    filter_type = "BBR_EnhedFilterInput",
    gql_var = "registreringstid",
    resource_name = "BBR_Enhed",
    where_builder = function(ids) list(bygning = list(`in` = ids)),
    nodes = nodes, node_names = node_names, batch_size = batch_size
  )
}
