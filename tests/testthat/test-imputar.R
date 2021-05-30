test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("imputa", {
  imputados <- imputar_profundidad_inferior(perfiles)
  expect_false(any(is.na(imputados$profundidad_inferior)))

  na <- which(is.na(perfiles$profundidad_inferior))

  expect_true(imputados$profundidad_inferior[na] == perfiles$profundidad_superior[na] + 5)
  imputados <- imputar_profundidad_inferior(perfiles, profundidad = 10)
  expect_true(imputados$profundidad_inferior[na] == perfiles$profundidad_superior[na] + 10)
})
