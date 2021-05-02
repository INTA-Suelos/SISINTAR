# listado_perfiles <- function() {
#   # Obtener la cantiadad de páginas a scrapear
#   pagina <- 1
#   url <- paste0("http://sisinta.inta.gob.ar/es/perfiles?filas=300&pagina=", pagina)
#   session <- rvest::session(url)
#
#   last <- rvest::html_node(session, ".pagination .last a")
#   last_page <- rvest::html_attr(last, "href")
#   last_page <- as.numeric(urltools::param_get(last_page, "pagina"))
#
#   last_page <- 2
#
#   # Descargar info de todos los perfiles
#   perfiles <- lapply(seq_len(last_page), function(p) {
#     url <- paste0("http://sisinta.inta.gob.ar/es/perfiles?filas=300&pagina=", p)
#     session <- rvest::session(url)
#     perfiles <- rvest::html_nodes(session, ".perfil_numero")
#
#     perfiles_url <- rvest::html_attr(perfiles, "href")
#     perfiles_id <- gsub("/es/perfiles/", "", perfiles_url)
#
#     paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfiles_id, ".csv")
#   })
#
#   # desde acá está sin terminar. Bajar todos estos datos es demasiado.
#
#   perfiles <- unlist(perfiles)
#
#   # p <- progress::progress_bar$new(total = length(perfiles))
#   # system.time(
#   # datos <- lapply(perfiles, function(url) {
#   #   file <- tempfile(fileext = ".csv")
#   #   download.file(url, file)
#   #   p$tick()
#   #   file
#   #   })
#   # )
#   # datos <- unlist(datos)
#
#
#
#
#
# }
#
#
