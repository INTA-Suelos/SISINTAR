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
#' \dontrun{
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
#'}
#' @export
buscar_perfiles <- function(rango_lon = NULL,
                            rango_lat = NULL,
                            rango_fecha = NULL,
                            clase = NULL,
                            serie = NULL,
                            actualizar_cada = 30) {
  if (!is.null(rango_lon)) {
    keep <- perfiles_meta$lon >= min(rango_lon) & perfiles_meta$lon <= max(rango_lon)
    perfiles_meta <- perfiles_meta[keep, ]
  }

  if (!is.null(rango_lat)) {
    keep <- perfiles_meta$lat >= min(rango_lat) & perfiles_meta$lat <= max(rango_lat)
    perfiles_meta <- perfiles_meta[keep, ]
  }

  if (!is.null(rango_fecha)) {
    rango_fecha <- as.Date(rango_fecha)
    keep <- perfiles_meta$fecha >= min(rango_fecha) & perfiles_meta$fecha <= max(rango_fecha)
    perfiles_meta <- perfiles_meta[keep, ]
  }

  if (!is.null(clase)) {
    keep <- lapply(clase, function(x) grepl(x, perfiles_meta$clase, ignore.case = TRUE))
    keep <- Reduce("|", keep)

    perfiles_meta <- perfiles_meta[keep, ]
  }

  if (!is.null(serie)) {
    hits <- serie %in% unique(perfiles_meta$serie)
    if (any(!hits)) {
      not_found <- serie[!hits]
      paste0("  * ", not_found)
      stop("Series inv\uE1lidas: \n", paste0("  * ", not_found))
    }

    keep <- perfiles_meta$serie %in% serie
    perfiles_meta <- perfiles_meta[keep, ]

  }

  perfiles_meta
}


