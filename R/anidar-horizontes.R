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
  perfiles_separado <- separar_perfiles(perfiles)
  horizontes_separados <- split(perfiles_separado[[2]], perfiles_separado[[2]][["perfil_id"]])

  horizontes_separados <- lapply(horizontes_separados, function(x) x[, colnames(x) != "perfil_id"])

  horizontes_separados <- data.frame(perfil_id = names(horizontes_separados),
                                     horizontes = I(horizontes_separados))
  anidado <- merge(horizontes_separados,
                   perfiles_separado[[1]], on = "perfil_id")

  anidado
}
