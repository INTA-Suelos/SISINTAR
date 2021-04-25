#' Obtiene perfiles de suelo
#'
#' @param perfil_ids vector de id numéricos de perfiles de suelo.
#' @param dir directorio donde descargar los archivos.
#'
#' @return
#' Un data.frame.
#'
#' @examples
#'
#' sis_perfiles(c(3238, 4634))
#'
#'
#' @export
sis_perfiles <- function(perfil_ids, dir = tempdir()) {
  urls <- paste0("http://sisinta.inta.gob.ar/es/perfiles/", perfil_ids, ".csv")
  files <- file.path(dir, paste0("sisinta_", perfil_ids, ".csv"))

  data <- lapply(seq_along(urls), function(i) {
    if (!file.exists(files[i])) {
      download.file(urls[i], files[i])
    }

    data <- read.csv(files[i])
    data
  })
  data <- do.call(rbind, data)


  return(data)
}

#' @export
as_SoilProfileCollection <- function(data) {

  perfil_cols <- colnames(data)[startsWith(colnames(data), "perfil_")]
  perfil_cols <- setdiff(perfil_cols, "perfil_id")

  formula <- as.formula(paste0("~ ", perfil_cols, collapse = " + "))

  aqp::depths(data) <- perfil_id ~ profundidad_superior + profundidad_inferior
  aqp::site(data) <- formula

  data
}
