#' dafogql: GraphQL Client for Datafordeler (BBR, DAR, and MAT)
#'
#' @description
#' `dafogql` provides functions to query selected
#' [GraphQL APIs](https://graphql.datafordeler.dk/) exposed by Datafordeler —
#' the Danish national data distribution platform. The package covers three
#' registers:
#'
#' - **BBR** (Bygnings- og Boligregistret) — the Building and Dwelling Register
#' - **DAR** (Danmarks Adresseregister) — the Danish Address Register
#' - **MAT** (Matriklen) — the Danish Cadastre
#'
#' All public functions share a common interface: they accept OAuth 2.0
#' credentials (`client_id` / `client_secret`), an ISO 8601 timestamp
#' (`time`), a vector of IDs to look up, and optional arguments to control
#' which fields are returned and how they are renamed. Internally, requests
#' are batched and cursor-based pagination is handled automatically, so callers
#' receive a single flat data frame regardless of result size.
#'
#' @section BBR functions:
#' | Function | Description |
#' |---|---|
#' | [bbr_bygning()] | Buildings (Bygning), queried by plot ID |
#' | [bbr_enhed()] | Dwelling units (Enhed), queried by building ID |
#' | [bbr_ejendomsrelation()] | Property–ownership relations (Ejendomsrelation), queried by BFE number |
#'
#' @section DAR functions:
#' | Function | Description |
#' |---|---|
#' | [dar_adress()] | Unit addresses (Adresse), queried by unit address ID |
#' | [dar_husnummer()] | Building addresses (Husnummer), queried by building address ID |
#' | [dar_adressepunkt()] | Address points with coordinates (Adressepunkt), queried by building address ID |
#'
#' @section MAT functions:
#' | Function | Description |
#' |---|---|
#' | [mat_jordstykke()] | Cadastral parcels (Jordstykke), queried by plot ID |
#' | [mat_jordstykke2()] | Cadastral parcels (Jordstykke), queried by SFE (samlet fast ejendom) ID |
#'
#' @section Address washing helpers:
#' | Function | Description |
#' |---|---|
#' | [wash_bldg_adr()] | Validate free-text addresses against the Dataforsyningen *access address* (adgangsadresser) API and return matched building address IDs |
#' | [wash_unit_adr()] | Validate free-text addresses against the Dataforsyningen *address* (adresser) API and return matched unit address IDs |
#'
#' @section Authentication:
#' All GraphQL functions authenticate via OAuth 2.0 client credentials against
#' `https://auth.datafordeler.dk`.
#'
#' ```r
#' Sys.setenv(CLIENT_ID     = "<your-client-id>")
#' Sys.setenv(CLIENT_SECRET = "<your-client-secret>")
#' ```
#'
#' @section Typical workflow:
#' ```r
#' library(dafogql)
#'
#' client_id     <- Sys.getenv("CLIENT_ID")
#' client_secret <- Sys.getenv("CLIENT_SECRET")
#' time          <- "2026-01-01T00:00:00Z"
#'
#' # 1. Wash raw addresses to obtain building address IDs
#' bldg_adrs <- wash_bldg_adr(c("Rådhuspladsen 1, 1550 København V"))
#'
#' # 2. Fetch cadastral plot IDs from DAR Husnummer
#' husnumre <- dar_husnummer(client_id, client_secret, time,
#'                           bldg_adr_id = bldg_adrs$bldg_adr_id)
#'
#' # 3. Fetch building data from BBR
#' bygninger <- bbr_bygning(client_id, client_secret, time,
#'                          plot_id = husnumre$plot_id)
#' ```
#'
#' @section API limits:
#' Each request accepts at most **100 IDs**. The `batch_size` argument
#' (default `100L`) controls the batch size; values above 100 will be rejected
#' by the API.
#'
#' @references
#' - Datafordeler GraphQL API: <https://graphql.datafordeler.dk/>
#' - Datafordeler documentation: <https://datafordeler.dk/>
#' - Dataforsyningen address washing: <https://api.dataforsyningen.dk/>
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom httr2 oauth_client req_oauth_client_credentials request
#'   req_body_json req_perform resp_body_json req_retry req_throttle
#'   req_url_query resp_url_query
#' @importFrom jsonlite fromJSON
#' @importFrom stats setNames
## usethis namespace: end
NULL
