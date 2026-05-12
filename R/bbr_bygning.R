#' Query BBR Bygning via GraphQL
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          DateTime string in ISO 8601 format (e.g. "2026-03-16T00:00:00Z")
#' @param plot_id       Character vector of one or more plot IDs (Jordstykke)
#' @param nodes         Character vector of node field names to return from the query.
#'                      Defaults to \code{c("byg007Bygningsnummer",
#'                      "byg021BygningensAnvendelse", "byg026Opfoerelsesaar",
#'                      "byg027OmTilbygningsaar", "byg032YdervaeggensMateriale",
#'                      "byg033Tagdaekningsmateriale", "byg036AsbestholdigtMateriale",
#'                      "byg038SamletBygningsareal",
#'                      "byg039BygningensSamledeBoligAreal",
#'                      "byg040BygningensSamledeErhvervsAreal",
#'                      "byg041BebyggetAreal", "byg042ArealIndbyggetGarage",
#'                      "byg043ArealIndbyggetCarport", "byg044ArealIndbyggetUdhus",
#'                      "byg045ArealIndbyggetUdestueEllerLign",
#'                      "byg046SamletArealAfLukkedeOverdaekningerPaaBygningen",
#'                      "byg054AntalEtager", "byg056Varmeinstallation",
#'                      "byg057Opvarmningsmiddel", "byg058SupplerendeVarme",
#'                      "byg071BevaringsvaerdighedReference",
#'                      "byg404Koordinat \{crs wkt\}", "id_lokalId", "jordstykke",
#'                      "husnummer", "status")}. Must be valid field names for the
#'                      BBR_Bygning type.
#' @param node_names    Optional named character vector mapping API field names to output
#'                      column names, e.g. \code{c(id_lokalId = "id")}. Fields not present
#'                      in the mapping are returned with their original API name. Pass
#'                      \code{NULL} to skip renaming entirely.
#' @param batch_size    Maximum number of IDs per request (default: 100). More than 100 will be rejected by the API.
#'
#'
#' @return A data frame with columns as specified by \code{nodes}, renamed according to \code{node_names} where a mapping exists
#'
#' @examples
#' \dontrun{
#' result <- bbr_bygning(
#'   client_id     = Sys.getenv("CLIENT_ID"),
#'   client_secret = Sys.getenv("CLIENT_SECRET"),
#'   time          = "2026-03-16T00:00:00Z",
#'   plot_id       = "0a3f50ca-201a-32b8-e044-0003ba298018"
#' )
#' }
#' @export
bbr_bygning <- function(
  client_id,
  client_secret,
  time,
  plot_id,
  nodes = c(
    "byg007Bygningsnummer",
    "byg021BygningensAnvendelse",
    "byg026Opfoerelsesaar",
    "byg027OmTilbygningsaar",
    "byg032YdervaeggensMateriale",
    "byg033Tagdaekningsmateriale",
    "byg036AsbestholdigtMateriale",
    "byg038SamletBygningsareal",
    "byg039BygningensSamledeBoligAreal",
    "byg040BygningensSamledeErhvervsAreal",
    "byg041BebyggetAreal",
    "byg042ArealIndbyggetGarage",
    "byg043ArealIndbyggetCarport",
    "byg044ArealIndbyggetUdhus",
    "byg045ArealIndbyggetUdestueEllerLign",
    "byg046SamletArealAfLukkedeOverdaekningerPaaBygningen",
    "byg054AntalEtager",
    "byg056Varmeinstallation",
    "byg057Opvarmningsmiddel",
    "byg058SupplerendeVarme",
    "byg071BevaringsvaerdighedReference",
    "byg404Koordinat {crs wkt}",
    "id_lokalId",
    "jordstykke",
    "husnummer",
    "status"
  ),
  node_names = c(
    "byg007Bygningsnummer" = "byg007_building_number",
    "byg021BygningensAnvendelse" = "byg021_bldg_type_code",
    "byg026Opfoerelsesaar" = "byg026_bldg_construction_year",
    "byg027OmTilbygningsaar" = "byg027_bldg_conversion_year",
    "byg032YdervaeggensMateriale" = "byg032_bldg_wall_code",
    "byg033Tagdaekningsmateriale" = "byg033_bldg_roof_code",
    "byg036AsbestholdigtMateriale" = "byg036_bldg_asbesthos_code",
    "byg038SamletBygningsareal" = "byg038_bldg_total_area",
    "byg039BygningensSamledeBoligAreal" = "byg039_bldg_residential_area",
    "byg040BygningensSamledeErhvervsAreal" = "byg040_bldg_business_area",
    "byg041BebyggetAreal" = "byg041_bldg_developed_area",
    "byg042ArealIndbyggetGarage" = "byg042_area_builtin_garage",
    "byg043ArealIndbyggetCarport" = "byg043_area_builtin_carport",
    "byg044ArealIndbyggetUdhus" = "byg044_area_builtin_outhouse",
    "byg045ArealIndbyggetUdestueEllerLign" = "byg045_area_builtin_sunroom",
    "byg046SamletArealAfLukkedeOverdaekningerPaaBygningen" = "byg046_area_closed_canopy",
    "byg054AntalEtager" = "byg054_bldg_nr_floor",
    "byg056Varmeinstallation" = "byg056_bldg_heating_code",
    "byg057Opvarmningsmiddel" = "byg057_bldg_heating_agent_code",
    "byg058SupplerendeVarme" = "byg058_bldg_sup_heating_code",
    "byg071BevaringsvaerdighedReference" = "byg071_bldg_fbb",
    "byg404Koordinat.crs" = "byg404_bldg_coord_crs",
    "byg404Koordinat.wkt" = "byg404_bldg_coord_wkt",
    "id_lokalId" = "building_id",
    "jordstykke" = "plot_id",
    "husnummer" = "building_bldg_adr_id",
    "status" = "status"
  ),
  batch_size = 100L
) {
  daf_query(
    client_id = client_id, client_secret = client_secret,
    time = time, ids = plot_id,
    api_path = "bbr/v2",
    query_var_type = "DafDateTime",
    filter_type = "BBR_BygningFilterInput",
    gql_var = "registreringstid",
    resource_name = "BBR_Bygning",
    where_builder = function(ids) {
      list(
        jordstykke = list(`in` = ids),
        # https://teknik.bbr.dk/kodelister/0/1/0/Livscyklus
        status = list(`in` = c("6", "7"))
      )
    },
    nodes = nodes, node_names = node_names, batch_size = batch_size,
    id_prep = unique
  )
}
