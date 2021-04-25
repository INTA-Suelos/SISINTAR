#' Buscar perfiles en base a ubicación y fechas
#'
#' @param rango_lon,rango_lat vectores numéricos con los límites
#' de longitud y latitud. La longitud tiene que estar entre -180º y 180º.
#' Los límites se definen como el mínimo y el máximo de cada vector.
#' @param rango_fecha vector tipo Date o que se puede cohercer a fecha con
#' `as.Date()` que define los límites de fechas.
#' @param clase vector de caracteres para filtrar la clase del perfil.
#' Se lo trata como una expresión regular que no distingue mayúsculas
#' y minúsculas. Si es un vector de longitud mayor a 1, se filtran las
#' clases que coincidan con al menos uno de los elementos (es decir, filtra con O).
#'
#'
#' @return
#' Un data.frame con los perfiles
#'
#' @examples
#' centro <- buscar_perfiles(rango_lat = c(-45, -30))
#' with(centro, plot(lon, lat))
#'
#' recientes <- buscar_perfiles(rango_fecha = c("2010-01-01", "2025-01-01"))
#' with(recientes, plot(lon, lat))
#'
#' # Periles donde la clase contiene "hapludol" o "natralbol"
#' buscar_perfiles(clase = c("hapludol", "natralbol"))
#'
#' @export
buscar_perfiles <- function(rango_lon = NULL,
                            rango_lat = NULL,
                            rango_fecha = NULL,
                            clase = NULL
                            ) {
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



  perfiles
}



actualizar_perfiles <- function() {
  file <- tempfile(fileext = ".geojson")
  utils::download.file("http://sisinta.inta.gob.ar/es/perfiles.geojson", file)

  f <- geojsonio::geojson_read(file)

  perfiles <- lapply(f$features, function(x) {

    as.data.frame(
      c(x$properties[c("id", "numero", "fecha", "clase")],
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
  dir <- tools::R_user_dir("SISINTAR", "data")

  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  file.path(dir, "perfiles.Rds")

}
