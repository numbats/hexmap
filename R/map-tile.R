#' Create a hexagon grid that tiles a geometry
#'
#' This function will tile a geometry using a specified number of hexagons.
#'
#' @param object An sf object or geometry to tile. It is recommended to first simplify this geometry to speed up the hexagon tiling.
#' @param n_tiles The number of tiles to use for representing the geometry.
#'
#' @return
#' A vector of hexagon geometries that tile the input geometry.
#'
#' @examples
#' library(ozmaps)
#' grid <- hex_grid(abs_ste, n_tiles = 75)
#'
#' library(ggplot2)
#' ggplot() +
#'   geom_sf(data = abs_ste) +
#'   geom_sf(data = grid, fill = "steelblue", alpha = 0.2)
#'
#' @importFrom sf st_bbox st_area st_as_sfc st_make_grid st_sf st_intersection
#' @export
hex_grid <- function(object, n_tiles = 100) {
  # Get map data
  map_width <- diff(unname(st_bbox(object))[c(1,3)])
  map_height <- diff(unname(st_bbox(object))[c(2,4)])
  map_area <- st_area(st_as_sfc(st_bbox(object)))
  map_ratio <- map_width / map_height

  # Compute ratio of land to map
  land_area <- sum(st_area(object))
  land_ratio <- as.numeric(land_area / map_area)

  # Number of hexagons to tile map such that ~n_tiles hexagons overlap land
  map_hex <- n_tiles / land_ratio

  # Size of hexagons
  hex_height <- map_height / sqrt(map_hex/map_ratio)
  hex_width <- hex_height / (1.5/sqrt(3))

  # Create grid
  hex_grid <- st_make_grid(object, cellsize = hex_width, square = FALSE)
  hex_grid <- st_sf(hex_grid, hex_id = seq_along(hex_grid))

  # Choose most overlapping n_tiles hexagons for map tiling
  hex_best <- st_intersection(hex_grid, object) %>%
    dplyr::group_by(!!sym("hex_id")) %>%
    dplyr::summarise(area = sum(st_area(hex_grid))) %>%
    dplyr::top_n(n_tiles, wt = !!sym("area")) %>%
    dplyr::pull(!!sym("hex_id"))

  # Return the best hexagons
  sf::st_geometry(hex_grid)[hex_grid$hex_id %in% hex_best]
}
