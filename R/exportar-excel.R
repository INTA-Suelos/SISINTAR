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
#' exportar_excel(perfiles, archivo)
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

