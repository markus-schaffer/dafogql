#' Robust Parallel HTTP Request Performance
#'
#' Performs HTTP requests in parallel with automatic retry logic for failed requests,
#' useful for handling API timeouts and temporary failures.
#'
#' @param reqs List of HTTP request objects (from httr2 package)
#' @param progress Character string or logical for progress display
#' @param max_active Integer specifying maximum number of concurrent requests.
#'   Default is 200.
#' @param max_retries Integer specifying maximum number of retry attempts.
#'   Default is 50.
#'
#' @return List of successful response objects
#'
#' @details
#' The function repeatedly attempts failed requests until either:
#' \itemize{
#'   \item All requests succeed
#'   \item Maximum retry limit is reached (throws error)
#' }
#'
#' This is useful for APIs that occasionally timeout without proper handling
#' by \code{req_retry}.
#'
#' @examples
#' \dontrun{
#' library(httr2)
#' reqs <- list(request1, request2, request3)
#' resps <- robust_perform(reqs, progress = "Fetching data", max_retries = 10)
#' }
#' @keywords internal
robust_perform <- function(reqs,
                           progress,
                           max_active = 200,
                           max_retries = 50) {
  resps <- httr2::req_perform_parallel(reqs,
    on_error = "continue",
    max_active = max_active,
    progress = progress
  )

  all_resps <- resps
  failed_reqs <- resps |>
    httr2::resps_failures() |>
    httr2::resps_requests()

  retry_count <- 0

  while (length(failed_reqs) > 0 && retry_count < max_retries) {
    retry_count <- retry_count + 1

    resps <- httr2::req_perform_parallel(failed_reqs,
      on_error = "continue",
      max_active = max_active,
      progress = paste0(progress, " re-try ", retry_count)
    )
    all_resps <- c(all_resps, resps)
    failed_reqs <- resps |>
      httr2::resps_failures() |>
      httr2::resps_requests()
  }

  if (length(failed_reqs) > 0) {
    stop(sprintf("%d requests failed after %d retries.", length(failed_reqs), max_retries))
  }
  all_resps <- all_resps |> httr2::resps_successes()
  return(all_resps)
}
