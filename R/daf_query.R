#' Shared internal GraphQL query engine for Datafordeler APIs
#'
#' Encapsulates the full pipeline: ID preparation, input validation,
#' query building, OAuth client creation, batched fetching with cursor-based
#' pagination, and column renaming.
#'
#' @param client_id      OAuth 2.0 client ID
#' @param client_secret  OAuth 2.0 client secret
#' @param time           DateTime string in ISO 8601 format
#'                       (e.g. \code{"2026-03-16T00:00:00Z"})
#' @param ids            Vector of IDs to query
#' @param api_path       API path appended to the base GraphQL endpoint
#'                       (e.g. \code{"dar/v2"}, \code{"bbr/v2"},
#'                       \code{"mat/v2"})
#' @param query_var_type GraphQL scalar type for the time variable
#'                       (e.g. \code{"DafDateTime"})
#' @param filter_type    GraphQL filter input type
#'                       (e.g. \code{"DAR_AdresseFilterInput"})
#' @param gql_var        Name of the GraphQL time variable
#'                       (\code{"virkningstid"} or \code{"registreringstid"})
#' @param resource_name  Name of the GraphQL resource field
#'                       (e.g. \code{"DAR_Adresse"})
#' @param where_builder  A function \code{function(batch_ids)} that returns the
#'                       \code{where} list for the GraphQL variables
#' @param nodes          Character vector of node field names to return
#' @param node_names     Named character vector mapping API field names to
#'                       output column names, or \code{NULL} to skip renaming
#' @param batch_size     Maximum number of IDs per request
#' @param id_prep        Optional function for ID pre-processing. Defaults to
#'                       \code{function(x) \{ x <- unique(x); x[!is.na(x)] \}}
#' @return A data frame of all nodes across all batches and pages
#' @keywords internal
daf_query <- function(client_id, client_secret, time, ids,
                      api_path, query_var_type, filter_type,
                      gql_var, resource_name,
                      where_builder,
                      nodes, node_names, batch_size,
                      id_prep = function(x) {
                        x <- unique(x)
                        x[!is.na(x)]
                      }) {
  TOKEN_URL <- "https://auth.datafordeler.dk/realms/distribution/protocol/openid-connect/token"
  API_ENDPOINT <- paste0("https://graphql.datafordeler.dk/", api_path)

  ids <- id_prep(ids)

  validate_graphql_inputs(client_id, client_secret, time, ids, batch_size)
  validate_nodes_inputs(nodes, node_names)

  node_fields <- paste(nodes, collapse = "\n      ")

  QUERY <- build_graphql_query(
    query_var_type = query_var_type,
    filter_type    = filter_type,
    gql_var        = gql_var,
    resource_name  = resource_name,
    node_fields    = node_fields
  )

  client <- build_oauth_client(client_id, client_secret, TOKEN_URL)

  fetch_batch <- function(batch_ids, after = NULL) {
    variables <- c(
      stats::setNames(list(time), gql_var),
      list(where = where_builder(batch_ids), after = after)
    )
    result <- graphql_request(client, API_ENDPOINT, QUERY, variables)
    list(
      pageInfo = result$data[[resource_name]]$pageInfo,
      nodes    = result$data[[resource_name]]$nodes
    )
  }

  out <- batch_graphql_query(ids, batch_size, fetch_batch)
  rename_nodes(out$nodes, node_names)
}
