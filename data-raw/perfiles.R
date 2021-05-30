## code to prepare `perfiles` dataset goes here

p <- buscar_perfiles()

# Necesitamos uno que tenga NA
na <- which(p$perfil_id == 3238)

perfiles <- get_perfiles(buscar_perfiles()[c(1:3, na), ])


usethis::use_data(perfiles, overwrite = TRUE)
