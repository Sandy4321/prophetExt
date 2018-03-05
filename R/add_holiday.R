#' @export
add_holiday <- function(holiday, name = as.character(ds), ds, lower = 0, upper = 0) {
  ds <- as.Date(ds)
  df <- data.frame(
    holiday = name,
    ds = ds,
    lower_window = lower,
    upper_window = upper,
    stringsAsFactors = FALSE
  )
  rbind(holiday, df)
}
