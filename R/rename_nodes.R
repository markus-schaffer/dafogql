#' Rename columns of a data frame according to a mapping
#'
#' @param df         A data frame
#' @param node_names Named character vector where names are current column names
#'                   and values are the desired new names. Pass \code{NULL} to
#'                   return \code{df} unchanged.
#' @return \code{df} with columns renamed where a mapping exists
#' @keywords internal
rename_nodes <- function(df, node_names) {
  if (is.null(node_names)) {
    return(df)
  }
  names(df) <- ifelse(
    names(df) %in% names(node_names),
    node_names[names(df)],
    names(df)
  )
  df
}
