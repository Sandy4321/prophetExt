#' Calendar plot
#'
#' @param object Object.
#' @param ... Other arguments.
#'
#' @export
prophet_calendar_plot <- function(object, ...) {
  UseMethod("prophet_calendar_plot")
}

#' @import ggplot2
#' @import dplyr
#' @importFrom lubridate year month day wday
#' @export
prophet_calendar_plot.prophet <- function(object, fcst, start = NULL, end = NULL, ...) {
  if (!("y" %in% colnames(fcst))) {
    fcst <- left_join(fcst, object$history, by = "ds")
  }
  if (!is.null(start)) {
    fcst <- fcst[fcst$ds >= set_date(start), ]
  }
  if (!is.null(end)) {
    fcst <- fcst[fcst$ds <= set_date(end), ]
  }
  resid_df <- mutate_(fcst, resid = "y - yhat")

  plot_calendar(df, resid_df)
}

#' @import ggplot2
#' @import dplyr
#' @importFrom lubridate year month day wday
#' @export
prophet_calendar_plot.prophet_outlier <- function(object, ...) {
  plot_calendar(df, object)
}

plot_calendar <- function(df, resid_df) {
  year_range <- range(year(resid_df$ds))
  dates <- seq(as.Date(sprintf("%d-01-01", year_range[1])),
               as.Date(sprintf("%d-12-31", year_range[2])), by="days")
  dates <- set_date(dates)

  df <- left_join(data.frame(ds = dates), resid_df, by="ds")

  df <- mutate_at(df, vars("ds") ,funs(year, month, day, wday))
  df <- mutate_(df, wday = "7 - wday")
  df <- group_by_(df, "year", "month")
  df <- mutate_(df, week = "cumsum(wday == 7 - 1)")
  df <- ungroup(df)
  df <- filter_(df, "!is.na(resid)")

  wdays_abbr <- rev(weekdays(as.Date("1970-01-03") + 1:7, abbreviate = TRUE))

  ggplot(df, aes_string("week", "wday")) +
    geom_tile(aes_string(fill = "resid")) +
    geom_text(aes_string(label = "day")) +
    facet_grid(year ~ month) + xlab("") + ylab("") +
    scale_y_continuous(breaks = 0:6, labels = wdays_abbr) +
    scale_fill_gradient2(low="red", high="blue") +
    scale_x_continuous(breaks = NULL) + theme_bw()
}
