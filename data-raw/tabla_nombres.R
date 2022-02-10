## code to prepare `tabla_nombres` dataset goes here

tabla_nombres <- data.table::fread("data-raw/tabla_nombres_sisinta.csv")
tabla_nombres <- as.data.frame(lapply(tabla_nombres, stringi::stri_escape_unicode))
usethis::use_data(tabla_nombres, overwrite = TRUE, internal = TRUE)
