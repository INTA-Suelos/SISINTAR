#' Inicial sesión en la página de SISINTA
#'
#' Esta función interna es utilizada por [get_perfiles()] para acceder a la web de
#' SISINTA con usuario y contraseña y poder descargar los perfiles no púplicos.
#'
#' @param usuario string, usualmente el mail.
#' @param pass string, contraseña asociada.
#'
log_in <- function(usuario, pass) {
  session <- rvest::session("http://sisinta.inta.gob.ar/es/usuarios/sign_in")
  form <- rvest::html_form(session)[[1]]
  form <- rvest::html_form_set(form,
                               `usuario[password]` = pass,
                               `usuario[email]` = usuario)
  session <- rvest::session_submit(session, form)

  result <- httr::content(session$response, as = "text")

  fail <- grepl("Email o contrase\u00f1a no v\u00E1lidos", result)
  if (fail) {
    stop("Email o contrase\u00f1a no v\u00E1lidos")
  }

  return(session)
}


download_perfil <- function(url, file, session) {
  if (is.null(session)) {
    utils::download.file(url, file, quiet = TRUE)
  } else {
    session <- rvest::session_jump_to(session,url)
    response <- httr::content(session$response, encoding = "UTF-8", as = "text")
    writeLines(response, file)
  }
  file

}
