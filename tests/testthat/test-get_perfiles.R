
test_that("descarga perfiles", {
  skip_if_offline()

  perfiles_id <- c(3238, 4634)
  expect_s3_class(p <- get_perfiles(perfiles_id), "data.frame")
  expect_true(nrow(p) > 0)
  expect_equal(unique(p$perfil_id), perfiles_id)
})


test_that("se puede cambiar el directorio de descarga", {
  skip_if_offline()

  dir <- file.path(tempdir(), "new_dir")
  expect_identical(p, p2)
  expect_true(length(list.files(dir)) == 2)
})


test_that("hay warnigns para perfiles privados", {
  skip_if_offline()

  expect_warning(expect_null(get_perfiles(4609), "No se pudieron descargar"))
  expect_error(get_perfiles(4609, parar_en_error = TRUE))
  expect_warning(p3 <- get_perfiles(c(perfiles_id, 4609)))
  expect_equal(p, p3)
})

test_that("funcionan las credenciales", {
  skip_if_offline()

  credenciales <- list(usuario = "paobcorrales@gmail.com",
                       pass = Sys.getenv("SISINTA.PASS"))
  expect_warning(p <- get_perfiles(4609, credenciales = credenciales), NA)
  expect_s3_class(p, "data.frame")
  expect_true(nrow(p) > 0)
  expect_equal(unique(p$perfil_id), 4609)
})


test_that("maneja malos inputs", {
  expect_error(get_perfiles(data.frame(x = 1)), "perfil_ids es un data.frame pero no tiene una columna llamada `perfil_id`")
})
