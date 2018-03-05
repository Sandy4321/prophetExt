#' @importFrom lubridate month day wday
#' @export
jpn_holidays <- function(begin, end) {
  if (!require("Nippon")) {
    stop('Please install.pacakges("Nippon")')
  }
  target_dates <- seq(as.Date(begin), as.Date(end), by="days")

  is.bon <- function(date) month(date) == 8 & day(date) %in% 14:16
  is.holiday <- function(date) Nippon::is.jholiday(date) | is.bon(date)

  hol_df <- data.frame(ds = target_dates) %>%
    filter(wday(ds) == 2) %>%
    filter(is.holiday(ds))

  two <- hol_df %>% filter(!is.holiday(ds + 1))
  three <- hol_df %>% filter(is.holiday(ds + 1), !is.holiday(ds + 2))
  four <- hol_df %>% filter(is.holiday(ds + 1), is.holiday(ds + 2), !is.holiday(ds + 3))

  sun_mon_holiday <- data.frame(
    holiday = "日月2連休",
    ds = two$ds,
    lower_window = -1,
    upper_window = 0,
    stringsAsFactors = FALSE
  )

  three_holiday <- data.frame(
    holiday = "日月火3連休",
    ds = three$ds,
    lower_window = -1,
    upper_window = 1,
    stringsAsFactors = FALSE
  )

  four_holiday <- data.frame(
    holiday = "日月火水4連休",
    ds = four$ds,
    lower_window = -1,
    upper_window = 2,
    stringsAsFactors = FALSE
  )

  tobiishi_hol <- data.frame(ds = target_dates) %>%
    filter(wday(ds) == 3) %>%
    filter(is.holiday(ds), !is.holiday(ds-1), is.holiday(ds+1))

  tobiishi <- data.frame(
    holiday = "火水木3連休",
    ds = tobiishi_hol$ds,
    lower_window = -3,
    upper_window = 2,
    stringsAsFactors = FALSE
  )

  tobiishi_hol2 <- data.frame(ds = target_dates) %>%
    filter(wday(ds) == 4) %>%
    filter(is.holiday(ds), !is.holiday(ds-1), is.holiday(ds+1))

  tobiishi2 <- data.frame(
    holiday = "水木金3連休",
    ds = tobiishi_hol2$ds,
    lower_window = -1,
    upper_window = 1,
    stringsAsFactors = FALSE
  )

  NewYear <- data.frame(
    holiday = "年末年始",
    ds = seq(as.Date("2014-01-01"), as.Date("2018-01-01"), by = "years"),
    lower_window = -4,
    upper_window = 1
  )

  holidays <- rbind(
    NewYear,
    sun_mon_holiday,
    three_holiday,
    four_holiday,
    tobiishi,
    tobiishi2
  )
  holidays
}
