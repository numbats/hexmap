
#' Create a hexagonal grid from geospatial polygons
#'
#' @param data An `sf` object.
#' @export
map_grid <- function(data) {

  check_map_grid_input(data)

  bb <- sf::st_bbox(data)


}


check_map_grid_input <- function(data) {
  if(!inherits(data, "sf")) abort("The input `data` is not an `sf` object.")
}


compute_ngrid_unit_square <- function(cellsize = NULL) {
  square <- matrix(c(0, 0,
                     0, 1,
                     1, 1,
                     1, 0,
                     0, 0),
                   ncol = 2,
                   byrow = TRUE) %>%
    list() %>%
    sf::st_polygon()

  grid <- sf::st_make_grid(square, cellsize = cellsize, square = FALSE)
  length(grid)
}

calculate_cellsize <- function(object, nhex) {

}
