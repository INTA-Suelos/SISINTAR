## code to prepare `tabla_nombres` dataset goes here

tabla_nombres <- data.table::fread("data-raw/tabla_nombres_sisinta.csv")
usethis::use_data(tabla_nombres, overwrite = TRUE)
