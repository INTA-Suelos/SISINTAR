# Elimina el achivo de perfiles.
unlink(file_perfiles())


test_that("busca perfiles", {
  skip_if(!check_inta())

  expect_message(p <<- buscar_perfiles(rango_lat = c(-45, -30)))
  r <- range(p$lat)
  expect_true(r[1] >= -45 & r[2] <= -30)

  expect_s3_class(buscar_perfiles(rango_lon = c(-45, -30)), "data.frame")

  fechas <- c("2010-01-01", "2025-01-01")
  p <- buscar_perfiles(rango_fecha = fechas)
  r <- range(p$fecha)
  expect_true(r[1] >= as.Date(fechas[1]) & r[2] <= as.Date(fechas[2]))


  p <- buscar_perfiles(clase = c("hapludol", "natralbol"))

  expect_true(all(grepl("hapludol", p$clase, ignore.case = TRUE) |  grepl("natralbol", p$clase, ignore.case = TRUE)))

  series <- c("Hansen", "Ramallo")
  p <- buscar_perfiles(serie = series)

  expect_equal(sort(unique(p$serie)), sort(series))

  expect_error(buscar_perfiles(serie = "asfdguifg"), "Series inv\uE1lidas")

  })
