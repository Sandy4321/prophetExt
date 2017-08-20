#' @import ggplot2
#' @export
plot.prophet_shf <- function(x, ...) {
  ggplot(x$observed, aes_string("x", "value")) +
    geom_point() + geom_smooth(method = "loess", se = FALSE)
}
