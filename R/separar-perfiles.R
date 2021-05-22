#' Separar datos de sitio y horizonte en dos tablas
#'
#' @param perfiles un data.frame con perfiles (salida de [get_perfiles()])
#'
#' @returns
#' Una lista con dos elementos. El elemento `sitios`, es un data.frmae con
#' la información de los sitios y el elemneto `horizontes` es un data.frame
#' con la información de horizontes.
#'
#'
#'
#' @export
separar_perfiles <- function(perfiles) {
  perfil_columns <- get_perfil_columns(perfiles)

  sitios <- unique(perfiles[perfil_columns])

  horizontes <- perfiles[, !(colnames(perfiles) %in% setdiff(perfil_columns, "perfil_id"))]

  list(sitios = sitios,
       horizontes = horizontes)
}

