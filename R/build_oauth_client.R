#' Build an OAuth2 client for a token endpoint
#'
#' @param client_id     OAuth 2.0 client ID
#' @param client_secret OAuth 2.0 client secret
#' @param token_url     Full URL of the OAuth 2.0 token endpoint
#' @return An httr2 oauth_client object
#' @keywords internal
build_oauth_client <- function(client_id, client_secret, token_url) {
  httr2::oauth_client(
    id        = client_id,
    secret    = client_secret,
    token_url = token_url
  )
}
