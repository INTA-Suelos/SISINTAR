#' Obtiene perfiles de suelo
#'
#' \code{get_perfies} descarga perfiles desde SISINTA o lee perfiles
#' descargados previamente.
#'
#' @param perfil_ids vector numérico de ids de perfiles de suelo.
#' Alternativamente puede ser un data.frame con una columna llamada
#' `perfil_id` (la salida de [buscar_perfiles()])
#' @param dir directorio donde se guardan los datos de perfiles o
#' donde se leen perfiles ya descargados. Por defecto, los perfiles
#' descargados se guardan en una carpeta temporal.
#' @param refresh boleano, fuerza la descarga de los datos para
#' actualizar los perfiles ya descargados.
#' @param parar_en_error tirar un error si algún perfil no está disponible
#' seguir intentando con los siguientes.
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
get_perfiles <- function(perfil_ids, dir = tempdir(), refresh = FALSE, parar_en_error = FALSE) {
  if (inherits(perfil_ids, "data.frame")) {
    perfil_ids <- perfil_ids$perfil_id
    if (is.null(perfil_ids)) {
      stop("perfil_ids es un data.frame pero no tiene una columna llamada `perfil_id`")
    }
  }


  urls <- paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfil_ids, ".csv")
  files <- file.path(dir, paste0("sisinta_", perfil_ids, ".csv"))


  pbar <- progress::progress_bar$new(total = length(perfil_ids), format = "[:bar] :percent - :eta")
  data <- lapply(seq_along(urls), function(i) {
    if (!file.exists(files[i]) | refresh == TRUE) {
      utils::download.file(urls[i], files[i], quiet = TRUE)
    }

    first_line <- readLines(files[i], 1)
    if (first_line == "<!DOCTYPE html>") {

      doc <- xml2::read_xml(files[i])
      selector <- ".//*[(@id = 'flash_error')]"  # sale de rvest:::make_selector("#flash_error")

      message <- xml2::xml_text(xml2::xml_find_first(doc, selector))
      if (is.na(message)) {
        message <- ""
      }

      unlink(files[i])
      if (parar_en_error) {
        stop("Error al descargar el perfil ", perfil_ids[i], " (#", i, "). Razón: ", message)
      }
      return(message)
    }

    data <- utils::read.csv(files[i])
    pbar$tick()
    data
  })

  fails <- vapply(data, is.character, logical(1))
  if (sum(fails) > 0) {
    fails_n <- which(fails)
    fails_ids <- perfil_ids[fails_n]
    messages <- unlist(data[fails])

    fails_text <- paste0("  * ", fails_ids, " (#", fails_n, "). Razón: ", messages, collapse = "\n")
    warning("Error al descargar los siguientes perfiles:\n", fails_text)
  }

  data <- do.call(rbind, data[!fails])

  return(data)
}
