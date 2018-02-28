#' Simulated Historical Forecast
#'
#' @param model Prophet model object.
#' @param periods Integer.
#' @param k Integer.
#' @param overlap Numeric.
#' @param data_hist Data.frame.
#' @param measure_func Function or character.
#'
#' @return A prophet shf object.
#'
#' @import prophet
#' @import dplyr
#' @importFrom stats loess predict
#' @export
prophet_shf <- function(model, periods, k = 3, overlap = 0.5, data_hist = model$history,
                        measure_func = c("MAPE", "MAE")) {
  if (is.character(measure_func)) {
    measure_func <- match.arg(measure_func)
    measure_func <- switch(measure_func,
                           "MAPE" = function(act, pred) abs(act - pred) / act,
                           "MAE" = function(act, pred) abs(act - pred))
  }
  data_hist$ds <- set_date(data_hist$ds)

  boundary <- get_boundary_ds(data_hist$ds, periods, k, overlap)

  observed <- mapply(function(ds_bound, iter) {
    df_train <- filter(data_hist, data_hist$ds <= ds_bound)
    df_test <- filter(data_hist, data_hist$ds >= ds_bound + boundary$interval,
                      data_hist$ds <= ds_bound + periods * boundary$interval)
    m <- prophet(
      df = data_hist,
      growth = model$growth,
      changepoints = model$changepoints,
      n.changepoints = model$n.changepoints,
      yearly.seasonality = model$yearly.seasonality,
      weekly.seasonality = model$weekly.seasonality,
      daily.seasonality = model$daily.seasonality,
      holidays = model$holidays,
      seasonality.prior.scale = model$seasonality.prior.scale,
      holidays.prior.scale = model$holidays.prior.scale,
      changepoint.prior.scale = model$changepoint.prior.scale,
      mcmc.samples = 0,
      interval.width = model$interval.width
    )
    fore <- predict(m, df_test)
    x <- as.integer(fore$ds - ds_bound)
    act <- df_test$y
    pred <- fore$yhat
    value <- measure_func(act, pred)
    data.frame(iter, x, value)
  }, boundary$boundary_ds, seq_len(k), SIMPLIFY = FALSE)
  observed <- Reduce(rbind, observed)

  fitted_model <- loess(value ~ x, data = observed)
  x <- seq_len(periods)
  estimated <- data.frame(x, value=predict(fitted_model, x))
  result <- list(estimated = estimated, observed = observed, fitted_model = fitted_model)
  class(result) <- "prophet_shf"
  result
}

get_boundary_ds <- function(ds, periods, k, overlap) {
  interval <- min(diff(ds))
  latest_ds <- max(ds)
  boundary_ds <- latest_ds - periods * interval
  boundary_ds <- c(boundary_ds, boundary_ds - ceiling(periods * interval * (1 - overlap)) * seq_len(k-1))
  list(boundary_ds = rev(boundary_ds), interval = interval)
}
