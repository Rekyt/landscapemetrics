#' TCA (class level)
#'
#' @description Total core area (Core area metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#' @param consider_boundary Logical if cells that only neighbour the landscape
#' boundary should be considered as core
#' @param edge_depth Distance (in cells) a cell has the be away from the patch
#' edge to be considered as core cell
#'
#' @details
#' \deqn{TCA = \sum_{j = 1}^{n} a_{ij}^{core} * (\frac{1} {10000})}
#' where here \eqn{a_{ij}^{core}} is the core area in square meters.
#'
#' TCA is a 'Core area metric' and equals the sum of core areas of all patches belonging
#' to class i. A cell is defined as core area if the cell has no neighbour with a different
#' value than itself (rook's case). In other words, the core area of a patch is all area that
#' is not an edge. It characterises patch areas and shapes of patches belonging to class i
#' simultaneously (more core area when the patch is large and the shape is rather compact,
#' i.e. a square). Additionally, TCA is a measure for the configuration of the landscape,
#' because the sum of edges increase as patches are less aggregated.
#'
#' \subsection{Units}{Hectares}
#' \subsection{Range}{TCA >= 0}
#' \subsection{Behaviour}{Increases, without limit, as patch areas increase
#' and patch shapes simplify. TCA = 0 when every cell in every patch of class i
#' is an edge.}
#'
#' @seealso
#' \code{\link{lsm_p_core}},
#' \code{\link{lsm_l_tca}}
#'
#' @return tibble
#'
#' @examples
#' lsm_c_tca(landscape)
#'
#' @aliases lsm_c_tca
#' @rdname lsm_c_tca
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' @export
lsm_c_tca <- function(landscape, directions, consider_boundary, edge_depth) UseMethod("lsm_c_tca")

#' @name lsm_c_tca
#' @export
lsm_c_tca.RasterLayer <- function(landscape, directions = 8, consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_tca_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_tca
#' @export
lsm_c_tca.RasterStack <- function(landscape, directions = 8, consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_tca_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_tca
#' @export
lsm_c_tca.RasterBrick <- function(landscape, directions = 8, consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_tca_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_tca
#' @export
lsm_c_tca.stars <- function(landscape, directions = 8, consider_boundary = FALSE, edge_depth = 1) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_tca_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_tca
#' @export
lsm_c_tca.list <- function(landscape, directions = 8, consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_tca_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

lsm_c_tca_calc <- function(landscape, directions, consider_boundary, edge_depth){

    core_area <- lsm_p_core_calc(landscape,
                                 directions = directions,
                                 consider_boundary = consider_boundary,
                                 edge_depth = edge_depth)

    core_area <- dplyr::summarise(dplyr::group_by(core_area, class),
                                  value = sum(value))

    tibble::tibble(
        level = "class",
        class = as.integer(core_area$class),
        id = as.integer(NA),
        metric = "tca",
        value = as.double(core_area$value)
    )
}
