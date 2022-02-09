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
#' variables continuas y categóricas, respectivamente. Ver [metodos_interpolacion].
#'
#' @returns
#' Un data.frame con los datos interpolados.
#'
#' @examples
#' interpolar_perfiles(perfiles, c("analitico_s", "analitico_t"))
#'
#' \dontrun{
#' # interpolar_spline() no acepta valores faltantes en las profundidades.
#' # Para imputar, ver imputar_profundidad_inferior().
#' interpolar_perfiles(perfiles, c("analitico_s", "analitico_t"),
#'                     metodo = interpolar_spline())
#'
#' }
#' # Horizontes cada 10 centímetros entre 0 y 100.
#' interpolar_perfiles(perfiles, c("analitico_s", "analitico_t"), seq(0, 100, 10))
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
  coords <- c("perfil_id", "profundidad_superior", "profundidad_inferior")
  numericas <- vapply(perfiles[variables], is.numeric, logical(1))

  vars <- list(vars_cat = perfiles[, variables[!numericas], drop = FALSE],
               vars_num = perfiles[, variables[numericas], drop = FALSE])

  bad_interpol <- vector("character")
  vars2 <- lapply(seq_along(vars), function(i) {
    if (ncol(vars[[i]]) == 0) {
      return(data.table::as.data.table(perfiles)[, .(perfil_id = unique(perfil_id))])
    } else {
      vars[[i]] <- cbind(vars[[i]], perfiles[, coords])
    }

    vars <- data.table::melt(data.table::setDT(vars[[i]]), id.vars = coords)
    if (i == 2) {
      metodo_fun <- metodo
    } else {
      metodo_fun <- metodo_categorico
    }

    vars2 <- vars[, metodo_fun(profundidad_superior,
                               profundidad_inferior,
                               value,
                               horizontes),
                  by = .(perfil_id, variable)]

    bad <- vars2[, .SD[any(!unique(c(profundidad_superior, profundidad_inferior)) %in% horizontes)], by = perfil_id]
    bad_interpol <<- unique(c(bad_interpol, unique(bad$perfil_id)))
    data.table::dcast(vars2, perfil_id + profundidad_superior + profundidad_inferior ~ variable,
                      value.var = "valor")
  })


  vars2 <- vars2[[1]][vars2[[2]], on = .NATURAL]

  if (length(bad_interpol) != 0) {
    text <- paste0("Se encontraron perfiles con profundidad m\u00E1xima menor al horizonte m\u00E1ximo pedido: \n",
                   paste(paste0(" * ", bad_interpol), collapse = "\n") )
    if (parar_en_error) {
      stop(text)
    } else {
      warning(text)
    }
  }

  datos_perfil <- unique(perfiles[, get_sitios_columns(perfiles), drop = FALSE])

  as.data.frame(merge(vars2, datos_perfil, by = "perfil_id"))
}

.datatable.aware <- TRUE
globalVariables(c(":=", "."))
