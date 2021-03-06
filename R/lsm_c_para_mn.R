#' PARA_MN (class level)
#'
#' @description Mean perimeter-area ratio (Shape metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be
#' connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{PARA_{MN} = mean(PARA[patch_{ij}]}
#' where \eqn{PARA[patch_{ij}]} is the perimeter area ratio of each patch.
#'
#' PARA_MN is a 'Shape metric'. It summarises each class as the mean of
#' each patch belonging to class i. The perimeter-area ratio describes the patch complexity
#' in a straightforward way. However, because it is not standarised to a certain shape
#' (e.g. a square), it is not scale independent, meaning that increasing the patch size
#' while not changing the patch form will change the ratio.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{PARA_MN > 0}
#' \subsection{Behaviour}{Approaches PARA_MN > 0 if PARA for each patch approaches PARA > 0,
#' i.e. the form approaches a rather small square. Increases, without limit, as PARA increases,
#' i.e. patches become more complex.}
#'
#' @seealso
#' \code{\link{lsm_p_para}},
#' \code{\link{mean}}, \cr
#' \code{\link{lsm_c_para_sd}},
#' \code{\link{lsm_c_para_cv}}, \cr
#' \code{\link{lsm_l_para_mn}},
#' \code{\link{lsm_l_para_sd}},
#' \code{\link{lsm_l_para_cv}}
#'
#' @return tibble
#'
#' @examples
#' lsm_c_para_mn(landscape)
#'
#' @aliases lsm_c_para_mn
#' @rdname lsm_c_para_mn
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' @export
lsm_c_para_mn <- function(landscape, directions) UseMethod("lsm_c_para_mn")

#' @name lsm_c_para_mn
#' @export
lsm_c_para_mn.RasterLayer <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_para_mn_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_para_mn
#' @export
lsm_c_para_mn.RasterStack <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_para_mn_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_para_mn
#' @export
lsm_c_para_mn.RasterBrick <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_para_mn_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_para_mn
#' @export
lsm_c_para_mn.stars <- function(landscape, directions = 8) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_para_mn_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_para_mn
#' @export
lsm_c_para_mn.list <- function(landscape, directions = 8) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_para_mn_calc,
                     directions = directions)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

lsm_c_para_mn_calc <- function(landscape, directions){

    para <- lsm_p_para_calc(landscape, directions = directions)

    para_mn <- dplyr::summarise(dplyr::group_by(para, class),
                                value = mean(value))

    tibble::tibble(
        level = "class",
        class = as.integer(para_mn$class),
        id = as.integer(NA),
        metric = "para_mn",
        value = as.double(para_mn$value)
    )
}
