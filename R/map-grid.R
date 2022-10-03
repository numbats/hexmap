
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
