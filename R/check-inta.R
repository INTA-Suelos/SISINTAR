#' Evalúa conexión con el servidor de SISINTA
#'
#' @return
#' Un valor lógico indicando si se puede establecer conexión con el servidor
#'
#' @export
check_sisinta <- function() {
  host <- "http://sisinta.inta.gob.ar/"
  RCurl::url.exists(host, timeout = 5)
}

fail_sisinta <- function() {
  hay_acceso <- check_sisinta()

  if (!hay_acceso) {
    fallo("No es posible acceder a SISINTA. Revise su conexi\u00F3n a internet y el estado de http://sisinta.inta.gob.ar/")
  }
}
