#' @importFrom lubridate ceiling_date floor_date
#' @export
make_changepoints <- function(begin, end, remove_tail = 1L) {
  changepoints <- seq(ceiling_date(begin, unit = "month"),
                      floor_date(end, unit = "month"), by = "months")
  head(changepoints, -remove_tail)
}
