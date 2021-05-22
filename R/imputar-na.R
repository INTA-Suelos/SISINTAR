#' Imputa valores faltantes en profundidad inferiror
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#' @param profundidad la profundidad asumida de la útlima capa
#'
#' @returns
#' Un data.frame igual al de entrada.
#'
#'
#' @export
imputar_profundidad_inferior <- function(perfiles, profundidad = 5) {
  profundidad_inferior <- profundidad_superior <- perfil_id <- NULL
  perfiles <- data.table::as.data.table(perfiles)

  perfiles[, profundidad_inferior := agregar_cm_fin(profundidad_inferior, profundidad_superior, profundidad),
           by = perfil_id]

  as.data.frame(perfiles)
}

agregar_cm_fin <- function(inferior, superior, cm) {
  n <- length(inferior)

  if (is.na(inferior[n])) {
    inferior[n] <- superior[n] + cm
  }
  as.numeric(inferior)
}
