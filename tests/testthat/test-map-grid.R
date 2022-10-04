test_that("calculate number of hexagons", {
  square <- matrix(c(0, 0,
                     0, 1,
                     1, 1,
                     1, 0,
                     0, 0),
                   ncol = 2,
                   byrow = TRUE) %>%
    list() %>%
    sf::st_polygon()

  expect_equal(calculate_cellsize(square, n = compute_ngrid_unit_square(cellsize = 0.5)),
               0.5)
})
