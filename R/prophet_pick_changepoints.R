#' Pick Cahngepoints from Prophet Object
#'
#' @param model prophet object
#' @param digit effective digit. Default 2.
#'
#' @export
prophet_pick_changepoints <- function(model, digit = 2) {
  delta <- as.vector(model$params$delta)
  cp_names <- model$changepoints
  while(any(abs(delta) < 10^-digit)) {
    ind <- which.min(abs(delta))
    cp_names <- cp_names[-ind]
    value <- delta[ind]
    delta <- delta[-ind]
    if (ind > length(delta)) ind <- ind - 1
    delta[ind] <- delta[ind] + value
  }
  trends <- model$params$k + cumsum(delta)
  cp_names <- c(model$start, cp_names)
  trends <- c(model$params$k, trends)
  delta <- c(0, delta)
  data.frame(changepoint = cp_names, trend = trends, delta = delta)
}
