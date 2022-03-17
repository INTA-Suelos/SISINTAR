check_inta <- function() {
  host <- "http://sisinta.inta.gob.ar/"
  RCurl::url.exists(host, timeout = 5)
}

fail_inta <- function() {
  hay_acceso <- check_inta()

  if (!hay_acceso) {
    error <- simpleError("No es posible acceder a SISINTA. Revise su conexión a internet y el estado de http://sisinta.inta.gob.ar/",
                         call = sys.call(-1))
    stop(error)
  }
}
