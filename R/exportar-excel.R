#' Exporta perfiles a excel
#'
#' La función exporta uno o más perfiles de SISINTA descargados o leidos
#' con [get_perfiles()] a un archivo excel donde los datos
#' de sitio están en una hoja llamada "sitios" y los horizontes, en una hoja
#' llamada "horizontes".
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#' @param archivo la ruta al archivo de salida.
#'
#' @returns
#' Devuelve la ruta al archivo de forma invisible.
#'
#' @examples
#'
#' archivo <- tempfile(fileext = ".xlsx")
#' exportar_excel(get_perfiles(c(3238, 4634)), archivo)
#'
#' @export
exportar_excel <- function(perfiles, archivo) {
  perfiles_separado <- separar_perfiles(perfiles)

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "sitios")
  openxlsx::writeDataTable(wb, perfiles_separado[["sitios"]], sheet = "sitios")

  openxlsx::addWorksheet(wb, "horizontes")
  openxlsx::writeDataTable(wb, perfiles_separado[["horizontes"]], sheet = "horizontes")

  openxlsx::saveWorkbook(wb, archivo, TRUE)
  invisible(archivo)
}

separar_perfiles <- function(perfiles) {

  perfil_columns <- get_perfil_columns(perfiles)

  sitios <- unique(perfiles[perfil_columns])


  horizontes <- perfiles[, !(colnames(perfiles) %in% setdiff(perfil_columns, "perfil_id"))]

  list(sitios = sitios,
       horizontes = horizontes)
}

