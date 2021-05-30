test_that("anida", {
  expect_error(anidado <- anidar_horizontes(perfiles), NA)
  expect_equal(nrow(anidado), 3)
  expect_true(!is.null(anidado$horizontes))
  expect_s3_class(anidado$horizontes[[1]], "data.frame")
})
