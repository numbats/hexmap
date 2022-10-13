#' Allocates tiled geometries to original map geometries
#'
#' This function will allocate tiles to their original geometries. This currently
#' requires a 1:1 mapping of geometries to their tiles.
#'
#' @param object An sf object or geometry that was used to be tiled.
#' @param tile An sf object produced with the `hex_grid()` function.
#'
#' @return
#' An sf dataset of hexagon geometries with their original data.
#'
#' @examples
#' library(ozmaps)
#' library(dplyr)
#' australia <- abs_ste %>% filter(NAME != "Other Territories")
#' grid <- hex_grid(australia, n_tiles = 8)
#' grid <- tile_allocate(australia, grid)
#'
#' library(ggplot2)
#' ggplot() +
#'   geom_sf(data = australia) +
#'   geom_sf(data = grid, aes(fill = NAME), alpha = 0.2)
#'
#' @importFrom sf st_centroid st_geometry
#' @export
tile_allocate <- function(object, tile) {
  require_package("geogrid")
  dist_matrix <- sp::spDists(
    as(st_centroid(st_geometry(object)), "Spatial"),
    as(st_centroid(st_geometry(tile)), "Spatial")
  )

  tile_allocation <- geogrid:::hungarian_cc(dist_matrix)
  tile_match <- apply(tile_allocation, MARGIN = 1L, FUN = function(x) which(x==1L))
  st_geometry(object) <- tile[tile_match]
  object
}
