## code to prepare `tabla_nombres` dataset goes here

tabla_nombres <- data.table::fread("data-raw/tabla_nombres_sisinta.csv")
colnames(tabla_nombres) <- tolower(colnames(tabla_nombres))


tabla_nombres <- tabla_nombres[, .(nombre = nombre_r,
                                   nombre_largo = nombre_sisinta,
                                   descripcion = descripción,
                                   unidad = unidades,
                                   nombre_csv)]

usethis::use_data(tabla_nombres, overwrite = TRUE)
