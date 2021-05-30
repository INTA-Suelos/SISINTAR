check_inta <- function() {
  host <- "http://sisinta.inta.gob.ar/"
  RCurl::url.exists(host, timeout = 5)
}
