#' Métodos de interpolación
#'
#'
#' @details
#'
#' `interpolar_promedio_ponderado` blabalbalba
#'
#' @export
#' @rdname metodos_interpolacion
interpolar_promedio_ponderado <- function() {
  function(superior, inferior, y, horizontes) {
  # Do not interpolate below max depth
  max_depth <- max(inferior, na.rm = TRUE)
  if (max(horizontes) > max_depth) {
    horizontes <- horizontes[horizontes <= max_depth]
    horizontes <- unique(sort(c(horizontes,  max(inferior, na.rm = TRUE))))
  }
  x <- c(superior, inferior[length(inferior)])
  # horizontes_validos <- horizontes[horizontes <= max(x, na.rm = TRUE)]
  y <- c(y, y[length(y)])

  d <- id <- x2 <- .N <-  NULL
  temp <- data.table::as.data.table(stats::approx(x, y,
                                                  xout = sort(unique(c(x, horizontes))),
                                                  method = "constant"))


  temp[, d := c(diff(x), 0)]
  # Si el y siguiente es un dato faltante, entonces en realidad no sirve.
  temp[, d := ifelse(is.na(data.table::shift(y, -1)), NA, d)]
  temp[, id := cumsum(x  %in% horizontes)]
  temp <- temp[, .(x = min(x), y = stats::weighted.mean(y, d)), by = id]
  temp <- temp[x %in% horizontes]
  temp <- temp[,  .(x, y)]
  temp[, x2 := data.table::shift(x, n = -1)]
  data.table::setnames(temp, c("x", "x2", "y"), c("profundidad_superior", "profundidad_inferior", "valor"))
  return(temp[-.N, ])
}
}
