#' COHESION (landscape level)
#'
#' @description Patch Cohesion Index (Aggregation metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{COHESION = 1 - (\frac{\sum \limits_{i = 1}^{m} \sum \limits_{j = 1}^{n} p_{ij}} {\sum \limits_{i = 1}^{m} \sum \limits_{j = 1}^{n} p_{ij} \sqrt{a_{ij}}}) * (1 - \frac{1} {\sqrt{Z}}) ^ {-1} * 100}
#' where \eqn{p_{ij}} is the perimeter in meters, \eqn{a_{ij}} is the area in square
#' meters and \eqn{Z} is the number of cells.
#'
#' COHESION is an 'Aggregation metric'.
#'
#' \subsection{Units}{Percent}
#' \subsection{Ranges}{Unknown}
#' \subsection{Behaviour}{Unknown}
#'
#' @seealso
#' \code{\link{lsm_p_perim}},
#' \code{\link{lsm_p_area}}, \cr
#' \code{\link{lsm_l_cohesion}}
#'
#' @return tibble
#'
#' @examples
#' lsm_l_cohesion(landscape)
#'
#' @aliases lsm_l_cohesion
#' @rdname lsm_l_cohesion
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' Schumaker, N. H. 1996. Using landscape indices to predict habitat
#' connectivity. Ecology, 77(4), 1210-1225.
#'
#' @export
lsm_l_cohesion <- function(landscape, directions)
    UseMethod("lsm_l_cohesion")

#' @name lsm_l_cohesion
#' @export
lsm_l_cohesion.RasterLayer <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_cohesion_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_l_cohesion
#' @export
lsm_l_cohesion.RasterStack <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_cohesion_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_l_cohesion
#' @export
lsm_l_cohesion.RasterBrick <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_cohesion_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_l_cohesion
#' @export
lsm_l_cohesion.stars <- function(landscape, directions = 8) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_l_cohesion_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_l_cohesion
#' @export
lsm_l_cohesion.list <- function(landscape, directions = 8) {

    result <- lapply(X = landscape,
                     FUN = lsm_l_cohesion_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

lsm_l_cohesion_calc <- function(landscape, directions) {

    ncells_landscape <- dplyr::mutate(lsm_l_ta_calc(landscape, directions = directions),
                                      value = value * 10000 / prod(raster::res(landscape)))

    ncells_patch <- dplyr::mutate(lsm_p_area_calc(landscape, directions = directions),
                                  value = value * 10000 / prod(raster::res(landscape)))

    perim_patch <- lsm_p_perim_calc(landscape, directions = directions)

    denominator <- dplyr::summarise(dplyr::mutate(perim_patch,
                                                  value = value * sqrt(ncells_patch$value)),
                                    value = sum(value))

    cohesion <- dplyr::mutate(dplyr::summarise(perim_patch, value = sum(value)),
                              value = (1 - (value / denominator$value)) *
                                  ((1 - (1 / sqrt(ncells_landscape$value))) ^ - 1) * 100)

    tibble::tibble(
        level = "landscape",
        class = as.integer(NA),
        id = as.integer(NA),
        metric = "cohesion",
        value = as.double(cohesion$value)
    )
}
