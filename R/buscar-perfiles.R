#' Buscar perfiles en base a ubicación y fechas
#'
#' La primera vez que se corre la función de descargará el archivo
#' http://sisinta.inta.gob.ar/es/perfiles.geojson y se actualizará si el archivo
#' fue descargado previamente hace más de 30 días o cuando lo indique el
#' argumento actualizar_cada.
#'
#' @param rango_lon,rango_lat vectores numéricos con los límites
#' de longitud y latitud. La longitud tiene que estar entre -180º y 180º.
#' Los límites se definen como el mínimo y el máximo valor de cada vector.
#' @param rango_fecha vector tipo Date o que se puede cohercer a fecha con
#' `as.Date()` que define el rango de fechas a buscar.
#' @param clase vector de caracteres para filtrar la clase del perfil.
#' La función lo trata como una expresión regular que no distingue mayúsculas
#' y minúsculas. Si es un vector de longitud mayor a 1, se filtran las
#' clases que coincidan con al menos uno de los elementos (es decir, filtra con O).
#' @param serie vector con nombres de series. El nombre debe ser el mismo que
#' aparece en la serie. Si alguna serie no se encuentra, la función tira error.
#' @param actualizar_cada valor numérico que define cada cuantos días se actualiza el archivo
#' con la información de la base de datos.
#'
#'
#' @return
#' Un data.frame con los perfiles que cumplen las condiciones de búsqueda
#'
#' @examples
#' centro <- buscar_perfiles(rango_lat = c(-45, -30))
#' with(centro, plot(lon, lat))
#'
#' recientes <- buscar_perfiles(rango_fecha = c("2010-01-01", "2025-01-01"))
#' with(recientes, plot(lon, lat))
#'
#' # Perfiles donde la clase contiene "hapludol" o "natralbol"
#' buscar_perfiles(clase = c("hapludol", "natralbol"))
#'
#' # Perfiles de la serie Ramallo
#' buscar_perfiles(serie = "Ramallo")
#'
#' @export
buscar_perfiles <- function(rango_lon = NULL,
                            rango_lat = NULL,
                            rango_fecha = NULL,
                            clase = NULL,
                            serie = NULL,
                            actualizar_cada = 30
) {
  perfiles <- file_perfiles()
  actualizar_cada <- actualizar_cada*24*3600
  if (!file.exists(perfiles) | as.numeric(Sys.time()) - as.numeric(file.info(perfiles)$mtime) > actualizar_cada) {
    actualizar_perfiles()
  }
  perfiles <- readRDS(perfiles)

  if (!is.null(rango_lon)) {
    keep <- perfiles$lon >= min(rango_lon) & perfiles$lon <= max(rango_lon)
    perfiles <- perfiles[keep, ]
  }

  if (!is.null(rango_lat)) {
    keep <- perfiles$lat >= min(rango_lat) & perfiles$lat <= max(rango_lat)
    perfiles <- perfiles[keep, ]
  }

  if (!is.null(rango_fecha)) {
    rango_fecha <- as.Date(rango_fecha)
    keep <- perfiles$fecha >= min(rango_fecha) & perfiles$fecha <= max(rango_fecha)
    perfiles <- perfiles[keep, ]
  }

  if (!is.null(clase)) {
    keep <- lapply(clase, function(x) grepl(x, perfiles$clase, ignore.case = TRUE))
    keep <- Reduce("|", keep)

    perfiles <- perfiles[keep, ]
  }

  if (!is.null(serie)) {
    hits <- serie %in% unique(perfiles$serie)
    if (any(!hits)) {
      not_found <- serie[!hits]
      paste0("  * ", not_found)
      stop("Series inv\uE1lidas: \n", paste0("  * ", not_found))
    }

    keep <- perfiles$serie %in% serie
    perfiles <- perfiles[keep, ]

  }

  perfiles
}


actualizar_perfiles <- function() {
  file <- file_perfiles()

  # if (file.exists(file)) {
  #   return(file)
  # }
  message("Descargando informaci\u00F3n de perfiles...")
  file <- tempfile(fileext = ".geojson")
  utils::download.file("http://sisinta.inta.gob.ar/es/perfiles.geojson", file)

  f <- geojsonio::geojson_read(file)

  parse_serie <- function(serie) {
    if (is.null(serie)) {
      return(NA)
    } else {
      return(jsonlite::fromJSON(serie)$nombre)
    }
  }
  perfiles <- lapply(f$features, function(x) {
    as.data.frame(
      c(list(perfil_id = x$properties[["id"]]),
        x$properties[c("numero", "fecha", "clase")],
        serie = parse_serie(x$properties[["serie"]]),
        list(lon = x$geometry$coordinates[[1]],
             lat = x$geometry$coordinates[[2]]))
    )

  })
  perfiles <- do.call(rbind, perfiles)
  perfiles$fecha <- as.Date(perfiles$fecha, "%d/%m/%Y")
  file <- file_perfiles()
  saveRDS(perfiles, file)
  return(invisible(file))
}

file_perfiles <- function() {
  dir <- sisintar_datos()

  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  file.path(dir, "perfiles.Rds")
}


sisintar_datos <- function() {
  rappdirs::user_data_dir("SISINTAR")
}
