test_that("conveirte", {
  expect_warning(collection <- as_SoilProfileCollection(perfiles))
  expect_s4_class(collection, "SoilProfileCollection")


  # Solo los que no tienen NA
  p <- perfiles[perfiles$perfil_id %in% c(1, 3), ]
  expect_error(collection <- as_SoilProfileCollection(p), NA)
  expect_s4_class(collection, "SoilProfileCollection")
})
