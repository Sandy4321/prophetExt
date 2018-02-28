#' Pick changepoints from prophet object
#'
#' @param model Prophet model object.
#' @param thresh Double. Default 0.01.
#'
#' @return A data frame consists of changepoints, growth rates and delta (changes in the growth rates).
#'
#' @examples
#' \dontrun{
#' m <- prophet(df)
#' prophet_pick_changepoints(m)
#' }
#'
#' @export
prophet_pick_changepoints <- function(model, thresh = 0.01) {
  cp_index <- c(1, which(abs(model$params$delta) >= thresh) + 1)
  changepoints <- c(model$start, model$changepoints)[cp_index]
  growth_rate <- model$params$k + c(0, cumsum(model$params$delta))[cp_index]
  delta <- c(NA_real_, model$params$delta)[cp_index]
  df <- data.frame(changepoint = set_date(changepoints),
                   growth_rate = growth_rate, delta = delta)
  class(df) <- c("prophet_changepoint", class(df))
  df
}
