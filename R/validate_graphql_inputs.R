#' Validate common GraphQL function inputs
#'
#' Stops with an informative message when any standard argument is invalid.
#' Individual query functions may add their own extra checks on top.
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param time          ISO 8601 datetime string
#' @param ids           Character vector of UUIDs
#' @param batch_size    Positive integer
#' @keywords internal
validate_graphql_inputs <- function(client_id, client_secret, time, ids, batch_size) {
  stopifnot(
    "client_id must be a non-empty string"      = is.character(client_id) && nchar(client_id) > 0,
    "client_secret must be a non-empty string"  = is.character(client_secret) && nchar(client_secret) > 0,
    "time must be a non-empty string"           = is.character(time) && nchar(time) > 0,
    "ids must be a non-empty character vector"  = length(ids) > 0,
    "batch_size must be a positive integer"     = is.numeric(batch_size) && batch_size >= 1L
  )
}
