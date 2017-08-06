#' Calendar plot
#'
#' @param obj Object.
#' @param ... Other arguments.
#'
#' @export
prophet_calendar_plot <- function(obj, ...) {
  UseMethod("prophet_calendar_plot")
}

#' @import ggplot2
#' @import dplyr
#' @importFrom lubridate year month day wday
#' @export
prophet_calendar_plot.prophet_outlier <- function(obj, ...) {
  year_range <- range(year(obj$ds))
  dates <- seq(as.Date(sprintf("%d-01-01", year_range[1])),
               as.Date(sprintf("%d-12-31", year_range[2])), by="days")

  df <- left_join(data.frame(ds = dates), obj, by="ds")
  df <- mutate_each_(df, funs(year, month, day, wday), "ds")
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
    scale_fill_gradient(low="red", high="green") +
    scale_x_continuous(breaks = NULL)
}
