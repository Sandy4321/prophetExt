#' @import ggplot2
#' @import dplyr
#' @importFrom lubridate year month day wday
#' @export
plot.prophet_outlier <- function(x, type = c("r", "p"), ...) {
  type <- match.arg(type)
  year_range <- range(year(x$ds))
  dates <- seq(as.Date(sprintf("%d-01-01", year_range[1])),
               as.Date(sprintf("%d-12-31", year_range[2])), by="days")

  df <- left_join(data.frame(ds = dates), x, by="ds")
  df <- mutate_each_(df, funs(year, month, day, wday), "ds")
  df <- mutate_(df, wday = "7 - wday")
  df <- group_by_(df, "year", "month")
  df <- mutate_(df, week = "cumsum(wday == 7 - 1)")
  df <- ungroup(df)
  df <- filter_(df, "!is.na(resid)")

  wdays_abbr <- rev(weekdays(as.Date("1970-01-03") + 1:7, abbreviate = TRUE))

  target <- switch(type, r="resid", p="p_value")
  ggplot(df, aes_string("week", "wday")) +
    geom_tile(aes_string(fill = target)) +
    geom_text(aes_string(label = "day")) +
    facet_grid(year ~ month) + xlab("") + ylab("") +
    scale_y_continuous(breaks = 0:6, labels = wdays_abbr) +
    scale_fill_gradient(low="red", high="green") +
    scale_x_continuous(breaks = NULL)
}
