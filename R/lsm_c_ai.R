#' AI (class level)
#'
#' @description Aggregation index (Aggregation metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers
#'
#' @details
#' \deqn{AI = \Bigg[\frac{g_{ii}}{max-g_{ii}} \Bigg](100) }
#'
#' where \eqn{g_{ii}} is the number of like adjacencies based on the single-count method and
#' \eqn{max-g_{ii}} is the classwise maximum number of like adjacencies of class i.
#'
#' AI is an 'Aggregation metric'. It equals the number of like adjacencies divided
#' by the theoretical maximum possible number of like adjacencies for that class.
#' The metric is based on he adjacency matrix and the the single-count method.
#'
#' \subsection{Units}{Percent}
#' \subsection{Range}{0 <= AI <= 100}
#' \subsection{Behaviour}{Equals 0 for maximally disaggregated and 100
#'  for maximally aggregated classes.}
#'
#' @return tibble
#'
#' @seealso
#' \code{\link{lsm_l_ai}}
#'
#' @examples
#' lsm_c_ai(landscape)
#'
#' @aliases lsm_c_ai
#' @rdname lsm_c_ai
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' He, H. S., DeZonia, B. E., & Mladenoff, D. J. 2000. An aggregation index (AI)
#' to quantify spatial patterns of landscapes. Landscape ecology, 15(7), 591-601.
#'
#' @export
lsm_c_ai <- function(landscape) UseMethod("lsm_c_ai")

#' @name lsm_c_ai
#' @export
lsm_c_ai.RasterLayer <- function(landscape) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ai_calc)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_ai
#' @export
lsm_c_ai.RasterStack <- function(landscape) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ai_calc)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_ai
#' @export
lsm_c_ai.RasterBrick <- function(landscape) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ai_calc)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_ai
#' @export
lsm_c_ai.stars <- function(landscape) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_ai_calc)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_c_ai
#' @export
lsm_c_ai.list <- function(landscape) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_ai_calc)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

lsm_c_ai_calc <- function(landscape) {

    tb <- rcpp_get_coocurrence_matrix(raster::as.matrix(landscape),
                                      directions = as.matrix(4))

    like_adjacencies <- diag(tb) / 2

    area_class <- tibble::as.tibble(raster::freq(landscape, useNA = "no"))

    min_e <- dplyr::mutate(
        area_class,
        value = count * 10000,
        n = trunc(sqrt(count)),
        m = count - n ^ 2,
        min_e = dplyr::case_when(
            m == 0 ~ 2 * n * (n - 1),
            m <= n ~ 2 * n * (n - 1) + 2 * m - 1,
            m > n ~ 2 * n * (n - 1) + 2 * m - 2
        )
    )

    min_e <- dplyr::pull(min_e, min_e)

    ai <- (like_adjacencies / min_e) * 100
    ai[is.nan(ai)] <- NA

    tibble::tibble(
        level = "class",
        class = as.integer(sort(unique(raster::values(landscape)))),
        id = as.integer(NA),
        metric = "ai",
        value = as.double(ai)
    )
}
