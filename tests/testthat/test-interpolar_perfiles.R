# Solo los que no tienen NA
p <- perfiles[perfiles$perfil_id %in% c(1, 3), ]
variables <- c("sum_bases", "cic")
test_that("interpola promedio ponderado", {
  expect_warning(expect_s3_class(interpolar_perfiles(p, variables), "data.frame"))

  d <- seq(0, 90, by = 10)
  p_i <- interpolar_perfiles(p, variables, horizontes = d)
  expect_identical(unique(c(p_i$profundidad_superior, p_i$profundidad_inferior)), d)
})


test_that("interpola spline", {
  d <- seq(0, 50, by = 5)
  expect_error(p_i <- interpolar_perfiles(p, variables,
                                          horizontes = d,
                                          metodo = interpolar_spline()), NA)

  expect_identical(unique(c(p_i$profundidad_superior, p_i$profundidad_inferior)), d)
})


test_that("maneja NAs", {
  d <- seq(0, 50, by = 5)

  pnas <- p
  pnas$sum_bases <- NA_real_

  expect_equal(unique(interpolar_perfiles(pnas, c("sum_bases"), horizontes = d)$sum_bases),
               NA_real_)
  expect_equal(unique(interpolar_perfiles(pnas, c("sum_bases"), horizontes = d, metodo = interpolar_spline())$sum_bases),
               NA_real_)

})

test_that("interpola valores categóricos",  {
  expect_warning(interpol_cat <- interpolar_perfiles(p, c("sum_bases", "textura")))

  expect_true(is.character(interpol_cat$textura))
})

