#' Imputa valores faltantes en profundidad inferior
#'
#' La función revisa si el perfil tiene valor faltante en la variable
#' \code{profundidad_inferior} e imputa un valor dado por \code{profundidad_superior}
#' más una constante definida por el argumento \code{profundidad}.
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#' @param profundidad la profundidad asumida de la ultima capa
#'
#' @returns
#' Un data.frame con las mismas filas y columnas que el objeto de entrada.
#'
#' @examples
#' imputar_profundidad_inferior(get_perfiles(c(3238)))
#' imputar_profundidad_inferior(get_perfiles(c(3238)), profundidad = 10)
#'
#' @export
imputar_profundidad_inferior <- function(perfiles, profundidad = 5) {
  profundidad_inferior <- profundidad_superior <- perfil_id <- NULL
  perfiles <- data.table::as.data.table(perfiles)

  perfiles[, c("profundidad_inferior", "produnfidad_superior") := agregar_cm_fin(profundidad_inferior, profundidad_superior, profundidad),
           by = perfil_id]

  as.data.frame(perfiles)
}

agregar_cm_fin <- function(inferior, superior, cm) {
  n <- length(inferior)

  if (n > 1) {
    if (is.na(superior[n])) {
      superior[n] <- inferior[n-1]
    }

    if (is.na(inferior[n])) {
      inferior[n] <- superior[n] + cm
    }
  }


  list(inferior, superior)
}
