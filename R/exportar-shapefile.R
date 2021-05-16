#' Exportar perfiles en shapefile
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#' @param archivo la ruta al archivo de salida.
#'
#' @examples
#' perfiles <- get_perfiles(c(3238, 4634))
#' archivo <- tempfile(fileext = ".shp")
#' # exportar_shapefile(perfiles, archivo)
#'
#' @export
exportar_shapefile <- function(perfiles, archivo) {
  perfiles_anidados <- anidar_horizontes(perfiles)

  sf_perfil <- sf::st_as_sf(perfiles_anidados,
                            coords = c("perfil_ubicacion_longitud", "perfil_ubicacion_latitud"),
                            crs = "+proj=longlat +datum=WGS84")

  sf::st_write(sf_perfil, dsn = archivo,
               driver = "ESRI Shapefile")

}


anidar_horizontes <- function(perfiles) {
  perfiles_separado <- separar_perfiles(perfiles)
  horizontes_separados <- split(perfiles_separado[[2]], perfiles_separado[[2]][["perfil_id"]])

  horizontes_separados <- lapply(horizontes_separados, function(x) x[, colnames(x) != "perfil_id"])

  horizontes_separados <- data.frame(perfil_id = names(horizontes_separados),
                                     horizontes = I(horizontes_separados))
  anidado <- merge(horizontes_separados,
             perfiles_separado[[1]], on = "perfil_id")

  anidado
}


