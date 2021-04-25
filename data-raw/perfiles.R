## code to prepare `pefiles` dataset goes here


file <- here::here("data-raw", "perfiles.geojson")
perfiles <- geojsonio::geojson_read(file)

perfiles <- lapply(perfiles$features, function(x) {
  as.data.frame(
    c(list(perfil_id = x$properties[["id"]]),
      x$properties[c("numero", "fecha", "clase")],
      list(lon = x$geometry$coordinates[[1]],
           lat = x$geometry$coordinates[[2]]))
  )
})


perfiles <- do.call(rbind, perfiles)

perfiles$fecha <- as.Date(perfiles$fecha, "%d/%m/%Y")

usethis::use_data(perfiles, overwrite = TRUE, internal = TRUE)
