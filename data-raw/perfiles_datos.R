

tabla_nombres <- data.table::fread("data-raw/tabla_nombres_sisinta.csv")
tabla_nombres <- as.data.frame(lapply(tabla_nombres, stringi::stri_escape_unicode))

perfiles_datos <- read.csv("data-raw/perfiles_datos.csv")

perfiles_datos <- as.data.frame(lapply(perfiles_datos, to_utf8))
# perfiles_datos <- normalizar_columnas(perfiles_datos, tabla_nombres = tabla_nombres)  # normaliza los nombres


perfiles_meta <- sf::st_read("data-raw/perfiles_meta.geojson", quiet = TRUE)
perfiles_meta[c("lon", "lat")] <- sf::st_coordinates(perfiles_meta)
perfiles_meta["serie"] <- unname(vapply(perfiles_meta$serie, function(x) {
  if (is.na(x)) return(NA_character_)
  jsonlite::fromJSON(x)[["nombre"]]
},
FUN.VALUE = character(1)))

perfiles_meta[c("url", "geometry")] <- NULL
colnames(perfiles_meta)[colnames(perfiles_meta) == "id"] <- "perfil_id"
perfiles_meta$fecha <- as.Date(perfiles_meta$fecha, "%d/%m/%Y")
perfiles_meta <- as.data.frame(perfiles_meta)


usethis::use_data(perfiles_datos, perfiles_meta, tabla_nombres, internal = TRUE,  overwrite = TRUE)
