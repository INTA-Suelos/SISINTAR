#' Métodos de interpolación
#'
#' SISINTAR implementa dos métodos de interpolación para obtener horizontes estandarizados
#' de las distintas variables disponibles. Estos métodos devuelven una función que recibe
#' los límites superior e inferior de cada capa, las observaciones a interpolar y los
#' horizontes o profundidades a los que se quiere interpolar cada variable.
#'
#' @details
#'
#' `interpolar_promedio_ponderado` utiliza un promedio ponderado para calcular los valores
#' interpolados en las capas definidas.
#'
#' `interpolar_spline` utiliza la funcione spline que preserva la masa de acuerdo a
#' Bishop T.F.A. el. al. (1999).
#'
#' @references
#' Bishop T.F.A. el. al. (1999) Modelling soil attribute depth functions with equal-area quadratic
#' smoothing splines. [https://doi.org/10.1016/S0016-7061(99)00003-8](https://doi.org/10.1016/S0016-7061(99)00003-8)
#'
#' @export
#' @rdname metodos_interpolacion
interpolar_promedio_ponderado <- function() {

  approx_safe <-  function(x, y = NULL, xout, method = "linear") {
    if (sum(!is.na(y)) < 2) {
      return(list(x = xout, y = rep(NA_real_, length(xout))))
    }

    stats::approx(x = x, y = y, xout = xout, method = method)
  }


  fun <- function(superior, inferior, obs, horizontes) {
    # Do not interpolate below max depth
    max_depth <- max(inferior, na.rm = TRUE)
    if (max(horizontes) > max_depth) {
      horizontes <- horizontes[horizontes <= max_depth]
      horizontes <- unique(sort(c(horizontes,  max(inferior, na.rm = TRUE))))
    }
    x <- c(superior, inferior[length(inferior)])
    # horizontes_validos <- horizontes[horizontes <= max(x, na.rm = TRUE)]
    obs <- c(obs, obs[length(obs)])

    y <- d <- id <- x2 <- .N <-  NULL

    temp <- data.table::as.data.table(approx_safe(x, obs,
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
  attr(fun, "sisintar_accepts_na") <- TRUE
  fun
}
