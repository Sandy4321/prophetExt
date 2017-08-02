#' Return ggplot layer objects to overlay prophet plot.
#'
#' @param object Object.
#' @param color Color.
#' @param ... Other arguments passed on to layers.
#'
#' @return A list of layer objects.
#'
#' @examples
#' \dontrun{
#' cpts <- prophet_pick_changepoints(m)
#' plot(m, fcst) + prophet_gglayer(cpts)
#'
#' outliers <- prophet_detect_outliers(m)
#' plot(m, fcst) + prophet_gglayer(outliers)
#' }
#'
#' @export
prophet_gglayer <- function(object, color = "#D55E00", ...) {
  UseMethod("prophet_gglayer")
}

#' @import ggplot2
#' @export
prophet_gglayer.prophet_changepoint <- function(object, color = "red", ...) {
  list(
    geom_line(aes_string("ds", "trend"), color = color, ...),
    geom_vline(xintercept = as.integer(object$changepoints[-1]),
               color = color, linetype = "dashed", ...)
  )
}

#' @import ggplot2
#' @export
prophet_gglayer.prophet_outlier <- function(object, color = "red", ...) {
  list(
    geom_point(data = object, aes_string("ds", "y"), color = color, ...)
  )
}
