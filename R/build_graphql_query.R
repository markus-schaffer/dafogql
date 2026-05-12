#' Build a GraphQL query string from a template
#'
#' @param query_var_type GraphQL scalar type for the time variable
#'                       (e.g. \code{"DafDateTime"})
#' @param filter_type    GraphQL filter input type
#'                       (e.g. \code{"DAR_AdresseFilterInput"})
#' @param gql_var        Name of the GraphQL query variable used for both
#'                       \code{virkningstid} and \code{registreringstid}
#'                       (e.g. \code{"virkningstid"} or \code{"registreringstid"})
#' @param resource_name  Name of the GraphQL resource field
#'                       (e.g. \code{"DAR_Adresse"})
#' @param node_fields    Whitespace-separated node fields already collapsed into
#'                       a single string
#' @return A GraphQL query string
#' @keywords internal
build_graphql_query <- function(query_var_type, filter_type, gql_var,
                                resource_name, node_fields) {
  sprintf(
    paste0(
      "query dar($%s: %s, $where: %s, $after: String) {\n",
      "  %s(\n",
      "    virkningstid: $%s\n",
      "    registreringstid: $%s\n",
      "    where: $where\n",
      "    after: $after\n",
      "  ) {\n",
      "    pageInfo {\n",
      "      hasNextPage\n",
      "      endCursor\n",
      "    }\n",
      "    nodes {\n",
      "      %s\n",
      "    }\n",
      "  }\n",
      "}"
    ),
    gql_var, query_var_type, filter_type,
    resource_name,
    gql_var, gql_var,
    node_fields
  )
}
