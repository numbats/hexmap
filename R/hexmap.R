

#' Convert map object into hex map
#'
#' @param x An sf map object.
#' @param name The name of the column that will contain the hex geometry.
#'   By default this is "hex".
#' @param geometry A string indicating the name of the
#' @export
add_hexmap <- function(x, name = "hex", select = "geometry") {
  xx <- sf::st_as_sf(x) %>%
    dplyr::mutate(.centroid = sf::st_centroid(x[[select]]),
                  .centroid_x = sapply(.centroid, function(.x) .x[1]),
                  .centroid_y = sapply(.centroid, function(.x) .x[1]),
                  id = NA_integer_) %>%
    dplyr::arrange(-.centroid_x, -.centroid_y) %>%
    dplyr::select(-.centroid, -.centroid_x, -.centroid_y)

  n <- nrow(xx) - sum(sapply(x$geometry, sf::st_is_empty))
  bb <- sf::st_bbox(xx)
  xdist <- bb[["xmax"]] - bb[["xmin"]]
  ydist <- bb[["ymax"]] - bb[["ymin"]]
  r <- xdist / ydist
  ny <- round(sqrt(n / r))
  nx <- round(r * ny)
  grid <- sf::st_make_grid(xx, square = FALSE, n = c(nx, ny)) %>%
    sf::st_as_sf() %>%
    dplyr::mutate(centroid = sf::st_centroid(x),
                  centroid_x = sapply(centroid, function(.x) .x[1]),
                  centroid_y = sapply(centroid, function(.x) .x[2])) %>%
    dplyr::arrange(-centroid_x, -centroid_y) %>%
    dplyr::group_by(cut(centroid_y, round(ny * 1.5))) %>%
    dplyr::arrange((-1)^dplyr::cur_group_id() * centroid_x, .by_group = TRUE) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(id = 1:dplyr::n(),
                  matched = FALSE)

  dd <- sf::st_distance(xx$geometry, grid$x)
  colnames(dd) <- grid$id

  for(i in 1:nrow(x)) {
    if(!any(is.na(dd[i,]))) {
      id <- as.integer(names(which.min(dd[i, which(!grid$matched)])))
      xx[[name]][i] <- sf::st_sfc(grid$x[[which(grid$id==id)]])
      xx$id[i] <- id
      grid$matched[which(grid$id==id)] <- TRUE
    }
  }
  xx %>%
    dplyr::mutate({{name}} := sf::st_sfc(xx[[name]], crs = sf::st_crs(xx[[select]])))

}

#' Map transition for animation
#'
#' This function transforms the data in the long form so that the transition
#' from the first map to the second map can be seen in the animation. This function
#' is like `tidyr::pivot_longer` but works for sf objects (error is given
#' `tidyr::pivot_longer` when combining `sf` objects).
#'
#' @param x An sf map object with two maps.
#' @param map_from,map_to Unquoted name of the column with the map to
#'  transition from/to.
#' @param name The name of the column with the map object.
#' @export
transition_map_data <- function(x, map_from, map_to, name = "geometry") {
  xx <- dplyr::as_tibble(x) %>%
    dplyr::filter(!is.na(id))
  dmap_from <- xx %>%
    dplyr::select(-{{map_from}}) %>%
    dplyr::rename({{name}} := {{map_to}}) %>%
    dplyr::mutate(type = rlang::as_string(rlang::enexpr(map_to)))

  xx %>%
    dplyr::select(-{{map_to}}) %>%
    dplyr::rename({{name}} := {{map_from}}) %>%
    dplyr::mutate(type = rlang::as_string(rlang::enexpr(map_from))) %>%
    dplyr::bind_rows(dmap_from)

}
