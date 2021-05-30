test_that("exporta a archivo", {
  archivo <- tempfile(fileext = ".xlsx")
  expect_error(exportar_excel(perfiles, archivo), NA)

  expect_true(file.exists(archivo))
})
