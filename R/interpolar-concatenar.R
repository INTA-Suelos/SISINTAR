#' @param sep separador utilizado para concatenar los valores únicos de cada capa.
#'
#' @rdname metodos_interpolacion
#' @export
interpolar_concatenar <- function(sep = "|") {
  force(sep)

  fun <- function(superior, inferior, obs, horizontes) {
    if (all(is.na(superior)) || all(is.na(inferior))) {
      return(data.table::data.table(profundidad_superior = NA_real_,
                                    profundidad_inferior = NA_real_,
                                    valor = NA_character_))
    }

    # Do not interpolate below max depth
    max_depth <- max(inferior, na.rm = TRUE)
    if (max(horizontes) > max_depth) {
      horizontes <- horizontes[horizontes <= max_depth]
      horizontes <- unique(sort(c(horizontes,  max(inferior, na.rm = TRUE))))
    }


    superior_interp <- horizontes[-length(horizontes)]
    inferior_interp <- horizontes[-1]

    obs <- vapply(seq_along(superior_interp), function(i) {
      capas <- superior <= inferior_interp[i]
      capas <- capas[!is.na(capas)]

      if (sum(capas) == 0) {
        return(NA_character_)
      }

      inferior_capas <- inferior[capas]

      inferior_capas[inferior_capas > inferior_interp[i]] <- inferior_interp[i]
      superior_capas <- superior[capas]

      profundidad <- inferior_capas - superior_capas

      obs_capas <- tapply(profundidad, obs[capas], sum, simplify = FALSE)

      paste(names(obs_capas)[order(-unlist(obs_capas))], collapse = sep)
    }, character(1))


    data.table::data.table(profundidad_superior = superior_interp,
                           profundidad_inferior = inferior_interp,
                           valor = obs)
  }
  attr(fun, "sisintar_accepts_na") <- TRUE
  fun


}
