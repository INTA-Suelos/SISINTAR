#' Obtiene perfiles de suelo
#'
#' \code{get_perfies} descarga perfiles desde SISINTA o lee perfiles
#' descargados previamente.
#'
#' @param perfil_ids vector numérico de ids de perfiles de suelo.
#' @param dir directorio donde se guardan los datos de perfiles o
#' donde se leen perfiles ya descargados. Por defecto, los perfiles
#' descargados se guardan en una carpeta temporal.
#' @param refresh boleano, fuerza la descarga de los datos para
#' actualizar los perfiles ya descargados.
#'
#' @return
#' Un data.frame.
#'
#' @examples
#'
#' get_perfiles(c(3238, 4634))
#'
#'
#' @export
get_perfiles <- function(perfil_ids, dir = tempdir(), refresh = FALSE) {
  urls <- paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfil_ids, ".csv")
  files <- file.path(dir, paste0("sisinta_", perfil_ids, ".csv"))

  data <- lapply(seq_along(urls), function(i) {
    if (!file.exists(files[i]) | refresh == TRUE) {
      download.file(urls[i], files[i])
    }

    data <- read.csv(files[i])
    data
  })
  data <- do.call(rbind, data)


  return(data)
}
