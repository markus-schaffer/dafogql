#' Execute a GraphQL query in batches and combine the results
#'
#' Splits `ids` into chunks of at most `batch_size`, calls `fetch_fn` for each
#' chunk (looping through all pages via cursor-based pagination), then
#' row-binds the `nodes` data frames and returns the combined result.
#'
#' @param ids        Character vector of IDs to query
#' @param batch_size Maximum number of IDs per request
#' @param fetch_fn   A function that accepts a character vector of IDs and an
#'                   optional cursor string, and returns a list with elements
#'                   `$pageInfo` (containing `$hasNextPage` and `$endCursor`)
#'                   and `$nodes`
#' @return A list with:
#'   \item{page_info}{pageInfo from the last page of the last batch}
#'   \item{nodes}{Row-bound data frame of all nodes across all batches and pages}
#' @keywords internal
batch_graphql_query <- function(ids, batch_size, fetch_fn) {
  batches <- split(ids, ceiling(seq_along(ids) / batch_size))

  all_nodes <- vector("list", length(batches))
  last_page_info <- NULL

  for (i in seq_along(batches)) {
    batch_ids <- batches[[i]]
    after_cursor <- NULL
    batch_nodes <- list()

    repeat {
      result <- fetch_fn(batch_ids, after_cursor)
      batch_nodes <- c(batch_nodes, list(result$nodes))
      last_page_info <- result$pageInfo

      if (isTRUE(result$pageInfo$hasNextPage)) {
        after_cursor <- result$pageInfo$endCursor
      } else {
        break
      }
    }

    all_nodes[[i]] <- do.call(rbind, batch_nodes)
  }

  list(
    page_info = last_page_info,
    nodes     = do.call(rbind, all_nodes)
  )
}
