#' Execute a single GraphQL request
#'
#' @param client       An httr2 oauth_client (from [build_oauth_client()])
#' @param endpoint     Full URL of the GraphQL endpoint
#' @param query_string GraphQL query as a string
#' @param variables    Named list of GraphQL variables
#' @return Parsed JSON response body as an R list
#' @keywords internal
graphql_request <- function(client, endpoint, query_string, variables) {
  response <- httr2::request(endpoint) |>
    httr2::req_oauth_client_credentials(client = client) |>
    httr2::req_body_json(
      list(query = query_string, variables = variables),
      auto_unbox = TRUE
    ) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_is_error(response)) {
    stop(
      "GraphQL request failed with status: ", httr2::resp_status(response), "\n",
      httr2::resp_body_string(response)
    )
  }

  result <- response |>
    httr2::resp_body_string() |>
    jsonlite::fromJSON(flatten = TRUE)

  if (!is.null(result$errors)) {
    stop(
      "GraphQL returned errors:\n",
      jsonlite::toJSON(result$errors, pretty = TRUE, auto_unbox = TRUE)
    )
  }

  result
}
