#' Anida datos de horizontes
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#'
#' @returns
#' Un data.frame anidado. El rsultado tiene una fila por cada perfil y una
#' columna por cada dato del perfil más una columna llamada "horizontes" que
#' tiene un data.frame con los horizontes de ese perfil.
#'
#' @examples
#'
#' perfiles <- get_perfiles(c(3238, 4634))
#' anidar_horizontes(perfiles)
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
