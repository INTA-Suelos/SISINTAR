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
#' @param credenciales una lista con elementos "usuario" y "pass".
#'
#' @return
#' Un data.frame.
#'
#' @examples
#'
#' get_perfiles(c(3238, 4634, 4609))
#'
#' \dontrun{
#' get_perfiles(4609, credenciales = list(usuario = "usuario",
#'                                        pass = "pass"))
#' }
#'
#' @export
get_perfiles <- function(perfil_ids, dir = tempdir(), refresh = FALSE, parar_en_error = FALSE,
                         credenciales = NULL) {
  if (inherits(perfil_ids, "data.frame")) {
    perfil_ids <- perfil_ids$perfil_id
    if (is.null(perfil_ids)) {
      stop("perfil_ids es un data.frame pero no tiene una columna llamada `perfil_id`")
    }
  }

  urls <- paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfil_ids, ".csv")
  files <- file.path(dir, paste0("sisinta_", perfil_ids, ".csv"))

  if (!is.null(credenciales)) {
    session <- log_in(credenciales[["usuario"]],
                      credenciales[["pass"]])
  } else {
    session <- NULL
  }
  to_utf8 <- function(x) {
    if (!is.character(x)) return(x)

    Encoding(x) <- "UTF-8"
    x
  }

  pbar <- progress::progress_bar$new(total = length(perfil_ids), format = "[:bar] :percent - :eta")
  data <- lapply(seq_along(urls), function(i) {
    if (!file.exists(files[i]) | refresh == TRUE) {
      if (!dir.exists(dir)) {
        dir.create(dir, showWarnings = FALSE, recursive = TRUE)
      }
      download_perfil(urls[i], files[i], session)
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
        stop("Error al descargar el perfil ", perfil_ids[i], " (#", i, "). Raz\u00F3n: ", message)
      }
      return(message)
    }

    data <- utils::read.csv(files[i])

    # Tenemos que hacer esto porque adiviná si el archivo está
    # bien codificado...
    data <- as.data.frame(lapply(data, to_utf8))
    pbar$tick()
    data
  })

  fails <- vapply(data, is.character, logical(1))
  if (sum(fails) > 0) {
    fails_n <- which(fails)
    fails_ids <- perfil_ids[fails_n]
    messages <- unlist(data[fails])

    fails_text <- paste0("  * ", fails_ids, " (#", fails_n, "). Raz\u00F3n: ", messages, collapse = "\n")
    warning("No se pudieron descargar los siguientes perfiles:\n", fails_text)
  }
  data <- do.call(rbind, data[!fails])

  return(data)
}

