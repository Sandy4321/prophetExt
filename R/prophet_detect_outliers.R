#' Detect outliers using Grubbs test.
#'
#' @param model Prophet model object.
#' @param p_limit Numeric, limit of p-value for Grubbs test. Default 0.05.
#' @param recursive Logical, whether to search recursively. Default TRUE.
#'
#' @return A data frame consists of ds, y, residuals and p values.
#'
#' @examples
#' \dontrun{
#' m <- prophet(df)
#' prophet_detect_outliers(m)
#' }
#'
#' @import prophet
#' @importFrom outliers grubbs.test
#' @importFrom stats predict
#'
#' @export
prophet_detect_outliers <- function(model, p_limit = 0.05, recursive = TRUE) {
  data_hist <- model$history
  outlier_ds <- Sys.Date()[-1]
  y_values <- c()
  resid_values <- c()
  p_values <- c()
  while(TRUE) {
    data_hist <- data_hist[!(data_hist$ds %in% outlier_ds), ]
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
    future <- make_future_dataframe(m, 1)
    fore <- predict(m, future)
    resid_df <- merge(fore, data_hist, by="ds")
    resid_df$resid <- resid_df$y - resid_df$yhat
    resid_df <- resid_df[-nrow(resid_df), ]

    n_outlier <- length(outlier_ds)
    while(TRUE) {
      result_test <- grubbs.test(resid_df$resid, type = 10)
      if (result_test$p.value < p_limit) {
        if(startsWith(result_test$alternative, "lowest")) {
          ind <- which.min(resid_df$resid)
        } else {
          ind <- which.max(resid_df$resid)
        }
        outlier_ds <- c(outlier_ds, resid_df$ds[ind])
        y_values <- c(y_values, resid_df$y[ind])
        resid_values <- c(resid_values, resid_df$resid[ind])
        p_values <- c(p_values, result_test$p.value)
      } else {
        break
      }
      resid_df <- resid_df[-ind, ]
    }
    if (n_outlier == length(outlier_ds) || !recursive) {
      break
    } else {
      message(sprintf("Detect %d outliers", length(outlier_ds) - n_outlier))
    }
  }
  df <- data.frame(ds = outlier_ds, y = y_values,
                   resid = resid_values, p_value = p_values)
  df <- df[order(df$ds), ]
  rownames(df) <- seq_len(nrow(df))
  class(df) <- c("prophet_outlier", class(df))
  df
}
