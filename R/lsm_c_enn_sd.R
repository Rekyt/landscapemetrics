#' ENN_SD (class level)
#'
#' @description Standard deviation of euclidean nearest-neighbor distance (Aggregation metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#' @param verbose Print warning message if not sufficient patches are present
#'
#' @details
#' \deqn{ENN_{SD} = sd(ENN[patch_{ij}])}
#' where \eqn{ENN[patch_{ij}]} is the euclidean nearest-neighbor distance
#' of each patch.
#'
#' ENN_CV is an 'Aggregation metric'. It summarises each class as the standard
#' deviation of each patch belonging to class i. ENN measures the distance to the  nearest
#' neighbouring patch of the same class i. The distance is measured from edge-to-edge.
#' The range is limited by the cell resolution on the lower limit and the landscape extent
#' on the upper limit. The metric is a simple way to describe patch isolation. Because it is
#' scaled to the mean, it is easily comparable among different landscapes.
#'
#' \subsection{Units}{Meters}
#' \subsection{Range}{ENN_SD >= 0}
#' \subsection{Behaviour}{Equals ENN_SD = 0 if the euclidean nearest-neighbor distance is
#' identical for all patches. Increases, without limit, as the variation of ENN increases.}
#'
#' @seealso
#' \code{\link{lsm_p_enn}},
#' \code{\link{sd}}, \cr
#' \code{\link{lsm_c_enn_mn}},
#' \code{\link{lsm_c_enn_cv}}, \cr
#' \code{\link{lsm_l_enn_mn}},
#' \code{\link{lsm_l_enn_sd}},
#' \code{\link{lsm_l_enn_cv}}
#'
#' @return tibble
#'
#' @examples
#' lsm_c_enn_sd(landscape)
#'
#' @aliases lsm_c_enn_sd
#' @rdname lsm_c_enn_sd
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' McGarigal, K., and McComb, W. C. (1995). Relationships between landscape
#' structure and breeding birds in the Oregon Coast Range.
#' Ecological monographs, 65(3), 235-260.
#'
#' @export
lsm_c_enn_sd <- function(landscape, directions, verbose) UseMethod("lsm_c_enn_sd")

#' @name lsm_c_enn_sd
#' @export
lsm_c_enn_sd.RasterLayer <- function(landscape, directions = 8, verbose = TRUE) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_enn_sd
#' @export
lsm_c_enn_sd.RasterStack <- function(landscape, directions = 8, verbose = TRUE) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_enn_sd
#' @export
lsm_c_enn_sd.RasterBrick <- function(landscape, directions = 8, verbose = TRUE) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_enn_sd
#' @export
lsm_c_enn_sd.stars <- function(landscape, directions = 8, verbose = TRUE) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_enn_sd
#' @export
lsm_c_enn_sd.list <- function(landscape, directions = 8, verbose = TRUE) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_enn_sd_calc,
                     directions = directions,
                     verbose = verbose)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}


lsm_c_enn_sd_calc <- function(landscape, directions, verbose) {

    enn <- lsm_p_enn_calc(landscape,
                          directions = directions,
                          verbose = verbose)

    enn_sd <-  dplyr::summarize(dplyr::group_by(enn, class),
                                value = stats::sd(value))

    tibble::tibble(
        level = "class",
        class = as.integer(enn_sd$class),
        id = as.integer(NA),
        metric = "enn_sd",
        value = as.double(enn_sd$value)
    )

}
