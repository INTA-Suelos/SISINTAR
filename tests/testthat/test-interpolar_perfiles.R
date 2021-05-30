# Solo los que no tienen NA
p <- perfiles[perfiles$perfil_id %in% c(1, 3), ]

test_that("interpola promedio ponderado", {
  expect_warning(expect_s3_class(interpolar_perfiles(p, c("analitico_s", "analitico_t")), "data.frame"))

  d <- seq(0, 90, by = 10)
  p_i <- interpolar_perfiles(p, c("analitico_s", "analitico_t"), horizontes = d)
  expect_identical(unique(c(p_i$profundidad_superior, p_i$profundidad_inferior)), d)
})


test_that("interpola spline", {
  d <- seq(0, 50, by = 5)
  expect_error(p_i <- interpolar_perfiles(p, c("analitico_s", "analitico_t"), horizontes = d, metodo = interpolar_spline()), NA)

  expect_identical(unique(c(p_i$profundidad_superior, p_i$profundidad_inferior)), d)
})

