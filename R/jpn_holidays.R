#' @importFrom lubridate month day wday
#' @export
jpn_holidays <- function(begin, end) {
  if (!requireNamespace("Nippon")) {
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

  if(nrow(two) != 0){
    sun_mon_holiday <- data.frame(
      holiday = "日月2連休",
      ds = two$ds,
      lower_window = -1,
      upper_window = 0,
      stringsAsFactors = FALSE
    )
  } else {
    sun_mon_holiday <- data.frame(matrix(rep(NA, 5), nrow=1), stringsAsFactors = FALSE)[numeric(0), ]
    colnames(sun_mon_holiday) <- c("holiday", "ds", "lower_window", "upper_window")
  }

  if(nrow(three) != 0){
    three_holiday <- data.frame(
      holiday = "日月火3連休",
      ds = three$ds,
      lower_window = -1,
      upper_window = 1,
      stringsAsFactors = FALSE
    )
  } else {
    three_holiday <- data.frame(matrix(rep(NA, 5), nrow=1), stringsAsFactors = FALSE)[numeric(0), ]
    colnames(three_holiday) <- c("holiday", "ds", "lower_window", "upper_window")
  }

  if(nrow(four) != 0){
    four_holiday <- data.frame(
      holiday = "日月火水4連休",
      ds = four$ds,
      lower_window = -1,
      upper_window = 2,
      stringsAsFactors = FALSE
    )
  } else {
    four_holiday <- data.frame(matrix(rep(NA, 5), nrow=1), stringsAsFactors = FALSE)[numeric(0), ]
    colnames(four_holiday) <- c("holiday", "ds", "lower_window", "upper_window")
  }

  tobiishi_hol <- data.frame(ds = target_dates) %>%
    filter(wday(ds) == 3) %>%
    filter(is.holiday(ds), !is.holiday(ds-1), is.holiday(ds+1))

  if(nrow(tobiishi_hol) != 0){
    tobiishi <- data.frame(
      holiday = "火水木3連休",
      ds = tobiishi_hol$ds,
      lower_window = -3,
      upper_window = 2,
      stringsAsFactors = FALSE
    )
  } else {
    tobiishi <- data.frame(matrix(rep(NA, 5), nrow=1), stringsAsFactors = FALSE)[numeric(0), ]
    colnames(tobiishi) <- c("holiday", "ds", "lower_window", "upper_window")
  }

  tobiishi_hol2 <- data.frame(ds = target_dates) %>%
    filter(wday(ds) == 4) %>%
    filter(is.holiday(ds), !is.holiday(ds-1), is.holiday(ds+1))

  if(nrow(tobiishi_hol2) != 0){
    tobiishi2 <- data.frame(
      holiday = "水木金3連休",
      ds = tobiishi_hol2$ds,
      lower_window = -1,
      upper_window = 1,
      stringsAsFactors = FALSE
    )
  } else {
    tobiishi2 <- data.frame(matrix(rep(NA, 5), nrow=1), stringsAsFactors = FALSE)[numeric(0), ]
    colnames(tobiishi2) <- c("holiday", "ds", "lower_window", "upper_window")
  }

  NewYear <- data.frame(
    holiday = "年末年始",
    ds = seq(lubridate::ceiling_date(as.Date(begin), "year"), as.Date(end), by = "years"),
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
