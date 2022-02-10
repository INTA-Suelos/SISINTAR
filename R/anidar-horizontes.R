#' Anida datos de horizontes
#'
#' La función \code{anidar_horizontes} permite organizar la información de uno
#' o más perfiles y sus horizontes en un data.frame. Cada fila se corresponde con
#' un perfil y los datos de los horizontes se guardan en una columna de data.frames.
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#'
#' @returns
#' Un data.frame anidado. El resultado tiene una fila por cada perfil y una
#' columna por cada dato del perfil más una columna llamada "horizontes" que
#' contiene un data.frame con los horizontes de cada perfil.
#'
#' @examples
#'
#' perfiles <- get_perfiles(c(3238, 4634))
#' anidados <- anidar_horizontes(perfiles)
#' #Para trabajar con horizontes anidados o desanidarlos se puede utlizar la librería {tidyr}
#' #tidyr::unnest(anidados, cols = c(horizontes))
#'
#' @export
anidar_horizontes <- function(perfiles) {
  vars <- c("perfil_id", get_sitios_columns(perfiles))

  perfiles <- data.table::as.data.table(perfiles)
  perfiles <- perfiles[, list(horizontes = list(as.data.frame(.SD))), keyby = c(vars)]
  data.table::setDF(perfiles)

}


desanidar_horizontes <- function(perfiles) {
  vars <- colnames(perfiles)[colnames(perfiles) != "horizontes"]
  perfiles <- data.table::as.data.table(perfiles)[, horizontes[[1]], by  = vars]
  data.table::setDF(perfiles)
}
