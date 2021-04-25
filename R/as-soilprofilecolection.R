#' Objeto SoilProfileCollection
#'
#' Transforma un perfil de SISINTA en formato data.frame en un objeto
#' SoilProfileCollection del paquete \code{\link[aqp]}.
#'
#' @param perfiles data.frame con perfiles descargados o leidos con
#' la función \code{get_perfiles}.
#'
#' @return un objeto \code{\link[packagename]
#'
#' @examples
#'
#' perfiles <- get_perfiles(c(3238, 4634))
#' coleccion <- as_SoilProfileCollection(perfiles)
#'
#' @export
as_SoilProfileCollection <- function(perfiles) {

  perfil_cols <- colnames(perfiles)[startsWith(colnames(perfiles), "perfil_")]
  perfil_cols <- setdiff(perfil_cols, "perfil_id")

  formula <- as.formula(paste0("~ ", perfil_cols, collapse = " + "))

  aqp::depths(perfiles) <- perfil_id ~ profundidad_superior + profundidad_inferior
  aqp::site(perfiles) <- formula

  perfiles
}
