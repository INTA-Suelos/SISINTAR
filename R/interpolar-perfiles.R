#' Interpola perfiles
#'
#' La función genera perfiles normalizados a partir de horizontes estandarizados
#' utilizando alguno de los métodos disponibles.
#'
#' @param perfiles un data.frame con datos de perfiles
#' @param variables un vector de texto con los nombres de las variables
#' a interpolar
#' @param horizontes un vector numérico que determina los horizontes a
#' usar para la interpolación o un numérico único que determina la resolución
#' en centímetros.
#' @param parar_en_error tirar un error si algún perfil tiene una profundidad
#' máxima que es menor a la indicada. Si es FALSE, interpola hasta la máxima
#' profundidad disponible y tira un warning.
#' @param metodo,metodo_categorico el método de interpolación utilizado para
#' variables continuas y categóricas, respectivamente. Ver [interpolar_promedio_ponderado()].
#'
#' @returns
#' Un data.frame con los datos interpolados.
#'
#' @examples
#' interpolar_perfiles(perfiles, c("sum_bases", "cic"))
#'
#' \dontrun{
#' # interpolar_spline() no acepta valores faltantes en las profundidades.
#' # Para imputar, ver imputar_profundidad_inferior().
#' interpolar_perfiles(perfiles, c("sum_bases", "cic"),
#'                     metodo = interpolar_spline())
#'
#' }
#' # Horizontes cada 10 centímetros entre 0 y 100.
#' interpolar_perfiles(perfiles, c("sum_bases", "cic"), seq(0, 100, 10))
#'
#' @export
interpolar_perfiles <- function(perfiles, variables, horizontes = 30,
                                metodo = interpolar_promedio_ponderado(),
                                metodo_categorico = interpolar_concatenar(),
                                parar_en_error = FALSE) {
  profundidad_superior <- profundidad_inferior <- value <- NULL
  perfil_id <- variable <- .SD <- NULL

  # Si el método tiene atributo sisintar_accepts_na y es verdadero, entonces hace
  # la vista gorda a los NA.
  na_ok <- attr(metodo, "sisintar_accepts_na", TRUE)

  if (!isTRUE(na_ok)) {
    if (any(is.na(perfiles$profundidad_inferior))) {
      bad_perfil <- unique(perfiles[is.na(perfiles$profundidad_inferior), ,drop = FALSE ]$perfil_id)

      stop("Hay perfiles con profundidad inferior NA:\n ", paste0("  * ", bad_perfil),
           "\nImputar con `imputar_profundidad_inferior()`")
    }
  }

  if (length(horizontes) == 1) {
    range <- max(perfiles[["profundidad_inferior"]], na.rm = TRUE)
    horizontes <- seq(0, range, by = horizontes)
  }

  perfiles <- anidar_horizontes(perfiles)
  coords <- c("profundidad_superior", "profundidad_inferior")

  perfiles$horizontes <- lapply(perfiles$horizontes, function(p) {

    data <- lapply(variables, function(var) {
      if (is.numeric(p[[var]])) {
        metodo_fun <- metodo
      } else {
        metodo_fun <- metodo_categorico
      }

      data <- with(p, metodo_fun(profundidad_superior, profundidad_inferior, get(var), horizontes))
      colnames(data)[3] <- var
      data
    })

    data <- Reduce(function(x, y) merge(x, y, by = c("profundidad_superior", "profundidad_inferior")),
                   data)

    data
  })
  perfiles <- data.table::as.data.table(desanidar_horizontes(perfiles))

  bad <- perfiles[, .SD[any(!unique(c(profundidad_superior, profundidad_inferior)) %in% horizontes)], by = perfil_id]
  bad_interpol <- unique(bad$perfil_id)


  if (length(bad_interpol) != 0) {
    text <- paste0("Se encontraron perfiles con profundidad m\u00E1xima menor al horizonte m\u00E1ximo pedido: \n",
                   paste(paste0(" * ", bad_interpol), collapse = "\n") )
    if (parar_en_error) {
      stop(text)
    } else {
      warning(text)
    }
  }
  perfiles
}




