#' Obtiene perfiles de suelo
#'
#' Obtiene datos de perfiles.
#' Por defecto, primero intenta leer datos existentes en `dir`, si no existen,
#' usa los datos incluidos en el paquete, y si no existen, trata de descargarlos
#' desde SISINTA. Esto garantiza reproducibilidad del proyecto o bajo mismas
#' versiones del paquete y minimiza la dependencia de una conexión a internet.
#'
#' @param perfil_ids vector numérico de ids de perfiles de suelo.
#' Alternativamente puede ser un data.frame con una columna llamada
#' `perfil_id` (la salida de [buscar_perfiles()])
#' @param dir directorio donde se guardan los datos de perfiles o
#' donde se leen perfiles ya descargados. Por defecto, los perfiles
#' descargados se guardan en una carpeta temporal.
#' @param refresh boleano, fuerza descargar datos de SISINTA.
#' @param parar_en_error tirar un error si algún perfil no está disponible
#' en vez de seguir intentando con los siguientes.
#' @param credenciales una lista con elementos "usuario" y "pass".
#'
#' @return
#' Un data.frame.
#'
#' @examples
#'
#' \dontrun{
#' get_perfiles(c(3238, 4634, 4609))
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

  if (!dir.exists(dir)) {
    dir.create(dir)
  }

  if (!refresh) {
    fuentes <- list(get_perfil_dir(dir = dir),
                    get_perfil_paquete(dir = dir),
                    get_perfil_sisinta(dir = dir, session = log_in(credenciales[["usuario"]],
                                                                   credenciales[["pass"]])))
  } else {
    fuentes <- list(get_perfil_sisinta(dir = dir, session = log_in(credenciales[["usuario"]],
                                                                   credenciales[["pass"]])))
  }


  pbar <- progress::progress_bar$new(total = length(perfil_ids), format = "[:bar] :percent - :eta")

  get_perfil_uno <- function(perfil_id) {
    for (fuente in fuentes) {
      perfil <- fuente(perfil_id)
      if (!es_fallo(perfil)) {
        pbar$tick()
        return(perfil)
      }
    }

    if (parar_en_error) {
      stop(simpleError(paste0(perfil, " (perfil ", perfil_id, ")"), call = sys.call(-2)))
    }
    pbar$tick()
    return(perfil)
  }

  perfiles <- lapply(perfil_ids, get_perfil_uno)

  fails <- vapply(perfiles, es_fallo, logical(1))

  if (sum(fails) > 0) {
    fails_n <- which(fails)
    fails_ids <- perfil_ids[fails_n]
    mensajes <- unlist(perfiles[fails_n])

    fails_text <- paste0("  * ", fails_ids, " (#", fails_n, ") : ", mensajes, "\n")
    warning("No se pudieron descargar los siguientes perfiles:\n", fails_text)
  }

  if (sum(fails) == length(perfil_ids)) {
    return(perfiles_datos[0, ])
  }

  perfiles <- do.call(rbind, perfiles[!fails])

  perfiles$perfil_id <- as.character(perfiles$perfil_id)
  return(perfiles)
}


archivo_perfil <- function(perfil_id) {
  paste0("sisinta_", perfil_id, ".csv")
}

fallo <- function(mensaje, perfil_id = NULL) {
  structure(mensaje, class = "fallo")
}

es_fallo <- function(x) {
  inherits(x, "fallo")
}

get_perfil_dir <- function(dir = tempdir()) {
  force(dir)

  function(perfil_id) {
    file <- file.path(dir, archivo_perfil(perfil_id))

    if (!file.exists(file)) {
      return(fallo("Perfil no existente en directorio."))
    }

    return(utils::read.csv(file))
  }
}

get_perfil_paquete <- function(dir = tempdir()) {
  force(dir)

  function(perfil_id) {
    cual_perfil <- perfiles_datos[["perfil_id"]] == perfil_id

    if (!any(cual_perfil)) {
      return(fallo("Perfil no existente en paquete."))
    }
    perfil <- perfiles_datos[cual_perfil, ]

    utils::write.csv(perfil, file =  file.path(dir, archivo_perfil(perfil_id)), row.names = FALSE)

    return(perfil)
  }
}


to_utf8 <- function(x) {
  if (!is.character(x)) return(x)

  Encoding(x) <- "UTF-8"
  x
}


get_perfil_sisinta <- function(dir = tempdir(), session = NULL) {
  force(dir)

  # no forzamos session para que sólo se evalúe si esta funcin corre.
  # y lo copado es que sólo se evalúa la primera vez que se corre la función
  # de abajo.
  function(perfil_id) {
    status <- fail_sisinta()

    if (es_fallo(status)) {
      return(status)
    }

    url <- paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfil_id, ".csv")

    # Si el proceso se cancela, no queda el archivo posta mal formado
    tempfile <- tempfile()

    download_perfil(url, tempfile, session)

    first_line <- readLines(tempfile, 1)

    # Error al descargar el archivo
    if (first_line == "<!DOCTYPE html>") {
      return(fallos("Perfil no disponible en SISINTA"))
    }

    # El archivo está bien
    perfil <- utils::read.csv(tempfile)

    perfil$perfil_id <- as.character(perfil$perfil_id)
    # Tenemos que hacer esto porque adiviná si el archivo está
    # bien codificado...
    perfil <- as.data.frame(lapply(perfil, to_utf8))
    perfil <- normalizar_columnas(perfil)  # normaliza los nombres

    utils::write.csv(perfil, file =  file.path(dir, archivo_perfil(perfil_id)), row.names = FALSE)

    return(perfil)
  }
}


normalizar_columnas <- function(perfiles, tabla_nombres = tabla_nombres) {
  colnames(perfiles) <- stats::setNames(tabla_nombres$nombre, tabla_nombres$nombre_csv)[colnames(perfiles)]
  perfiles
}
