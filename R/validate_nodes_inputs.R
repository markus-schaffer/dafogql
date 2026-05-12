#' Validate nodes and node_names arguments
#'
#' @param nodes      Character vector of GraphQL node field names
#' @param node_names Named character vector mapping API field names to output
#'                   column names, or \code{NULL} to skip renaming
#' @keywords internal
validate_nodes_inputs <- function(nodes, node_names) {
  stopifnot(
    "nodes must be a non-empty character vector"          = is.character(nodes) && length(nodes) > 0,
    "node_names must be a named character vector or NULL" = is.null(node_names) || (is.character(node_names) && !is.null(names(node_names)))
  )
}
