#' Interpola perfiles
#'
#' La función genera perfiles normalizados a partir de horizontes estandarizados
#' utilizando alguno de los métodos disponibles.
#'
#' @param perfiles un data.frame con datos de perfiles
#' @param variables un vector de texto con los nombres de las variables
#' a interpolar
#' @param horizontes un vector numérico que determina los horizontes a
#' usar para la interpolación o un numérico único que determina la resolución
#' en centímetros.
#' @param parar_en_error tirar un error si algún perfil tiene una profundidad
#' máxima que es menor a la indicada. Si es FALSE, interpola hasta la máxima
#' profundidad disponible y tira un warning.
#'
#' @returns
#' Un data.frame con los datos interpolados.
#'
#' @examples
#' interpolar_perfiles(get_perfiles(c(3238, 4634)), c("analitico_s", "analitico_t"))
#'
#' # Horizontes cada 10 centímetros entre 0 y 100.
#' interpolar_perfiles(get_perfiles(c(3238, 4634)), c("analitico_s", "analitico_t"), seq(0, 100, 10))
#'
#' @export
interpolar_perfiles <- function(perfiles, variables, horizontes = 30,
                                parar_en_error = FALSE) {
  variables_string <- variables
  profundidad_superior <- profundidad_inferior <- value <- NULL
  perfil_id <- variable <- .SD <- NULL

  numericas <- vapply(perfiles[variables_string], is.numeric, logical(1))

  if (any(!numericas)) {
    stop("Las variables ", variables_string[!numericas], " no son num\u00e9ricas.")
  }

  if (length(horizontes) == 1) {
    range <- max(perfiles[["profundidad_inferior"]], na.rm = TRUE)
    horizontes <- seq(0, range, by = horizontes)
  }

  vars <- data.table::as.data.table(perfiles[, c("perfil_id", "profundidad_superior", "profundidad_inferior", variables_string)])
  vars <- data.table::melt(vars, id.vars = c("perfil_id", "profundidad_superior", "profundidad_inferior"))

  vars2 <- vars[, interpolar_promedio_ponderado(profundidad_superior,
                                                profundidad_inferior,
                                                value,
                                                horizontes),
                by = .(perfil_id, variable)]

  bad_interpol <- vars2[, .SD[any(!unique(c(profundidad_superior, profundidad_inferior)) %in% horizontes)], by = perfil_id]
  bad_interpol <- unique(bad_interpol$perfil_id)

  if (length(bad_interpol) != 0) {
    text <- paste0("Se encontraron perfiles con profundidad m\u00E1xima menor al horizonte m\u00E1ximo pedido: \n",
            paste(paste0(" * ", bad_interpol), collapse = "\n") )
    if (parar_en_error) {
      stop(text)
    } else {
      warning(text)
    }

  }

  vars2 <- data.table::dcast(vars2, perfil_id + profundidad_superior + profundidad_inferior ~ variable, value.var = "valor")

  datos_perfil <- unique(perfiles[, get_perfil_columns(perfiles)])


  as.data.frame(merge(vars2, datos_perfil, by = "perfil_id"))

}



interpolar_promedio_ponderado <- function(superior, inferior, y, horizontes) {
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

.datatable.aware <- TRUE
globalVariables(c(":=", "."))
