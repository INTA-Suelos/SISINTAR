#' Exportar perfiles en shapefile
#'
#' La función exporta uno o más perfiles de SISINTA descargados o leidos
#' con [get_perfiles()] en formato shapefile. !!! REQUIERE NOMBRES DE
#' COLUMNAS MÁS CORTOS
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





