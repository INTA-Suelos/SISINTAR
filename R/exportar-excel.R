#' Exporta perfiles a excel
#'
#' Exporta un data.frame con datos de perfiles a un archivo excel donde los datos
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

  wb <- xlsx::createWorkbook()
  xlsx::addDataFrame(perfiles_separado[["sitios"]], sheet = xlsx::createSheet(wb, "sitios"))
  xlsx::addDataFrame(perfiles_separado[["horizontes"]], sheet = xlsx::createSheet(wb, "horizontes"))

  xlsx::saveWorkbook(wb, archivo)
  invisible(archivo)
}

separar_perfiles <- function(perfiles) {

  perfil_columns <- get_perfil_columns(perfiles)

  sitios <- unique(perfiles[perfil_columns])


  horizontes <- perfiles[, !(colnames(perfiles) %in% setdiff(perfil_columns, "perfil_id"))]

  list(sitios = sitios,
       horizontes = horizontes)
}

