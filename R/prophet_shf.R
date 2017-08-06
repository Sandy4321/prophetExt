#' Simulated Historical Forecast
#'
#' @param model Prophet model object.
#' @param periods periods
#' @param freq freq
#' @param k k
#' @param overlap overlap
#'
#' @import prophet
#' @importFrom stats loess predict
#' @importFrom utils head tail
#' @export
prophet_shf <- function(model, periods, freq = "d", k = 3, overlap = 0.5) {
  N <- nrow(model$history)
  denom <- round(1 / (1 - overlap))
  overlap <- 1 / denom
  periods <- periods + periods %% denom  # periods to odd number
  preserve <- (k - 1) * periods / denom + periods
  n_history <- N - preserve - 1
  if (n_history < periods * 2) warning("History is too short.")
  result <- data.frame()
  while (n_history < N - periods) {
    data_hist <- head(model$history, n_history)
    m <- prophet(data_hist, growth = model$growth,
                 n.changepoints = model$n.changepoints,
                 yearly.seasonality = model$yearly.seasonality,
                 weekly.seasonality = model$weekly.seasonality,
                 holidays = model$holidays,
                 seasonality.prior.scale = model$seasonality.prior.scale,
                 changepoint.prior.scale = model$changepoint.prior.scale,
                 holidays.prior.scale = model$holidays.prior.scale,
                 mcmc.samples = model$mcmc.samples,
                 interval.width = model$interval.width,
                 uncertainty.samples = model$uncertainty.samples)
    future <- make_future_dataframe(m, periods, freq = freq)
    forecast <- predict(m, future)
    tmp <- merge(forecast, model$history, by="ds")
    pred <- tail(tmp$yhat, periods)
    act <- tail(tmp$y, periods)
    ape <- abs((act - pred) / act)
    df <- data.frame(x = 1:periods, ape = ape)
    result <- rbind(result, df)
    n_history <- n_history + periods / denom
  }
  # print(ggplot(result, aes_string(x=x, y="ape"))+ geom_point() + geom_smooth(method = "loess", se=FALSE))
  loess <- loess(ape ~ x, data = result)
  predict(loess, data.frame(x = 1:periods))
}
