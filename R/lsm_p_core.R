#' CORE (patch level)
#'
#' @description Core area (Core area metric)
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
#' \deqn{CORE = a_{ij}^{core}}
#' where \eqn{a_{ij}^{core}} is the core area in square meters
#'
#' CORE is a 'Core area metric' and equals the area within a patch that is not
#' on the edge of it. A cell is defined as core area if the cell has no
#' neighbour with a different value than itself (rook's case). It describes patch area
#' and shape simultaneously (more core area when the patch is large and the shape is
#' rather compact, i.e. a square).
#'
#' \subsection{Units}{Hectares}
#' \subsection{Range}{CORE >= 0}
#' \subsection{Behaviour}{Increases, without limit, as the patch area increases
#' and the patch shape simplifies (more core area). CORE = 0 when every cell in
#' the patch is an edge.}
#'
#' @seealso
#' \code{\link{lsm_c_core_mn}},
#' \code{\link{lsm_c_core_sd}},
#' \code{\link{lsm_c_core_cv}},
#' \code{\link{lsm_c_tca}}, \cr
#' \code{\link{lsm_l_core_mn}},
#' \code{\link{lsm_l_core_sd}},
#' \code{\link{lsm_l_core_cv}},
#' \code{\link{lsm_l_tca}}
#'
#' @return tibble
#'
#' @importFrom stats na.omit
#'
#' @examples
#' lsm_p_core(landscape)
#'
#' @aliases lsm_p_core
#' @rdname lsm_p_core
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' @export
lsm_p_core <- function(landscape, directions, consider_boundary, edge_depth) UseMethod("lsm_p_core")

#' @name lsm_p_core
#' @export
lsm_p_core.RasterLayer <- function(landscape, directions = 8,
                                   consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_core_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_p_core
#' @export
lsm_p_core.RasterStack <- function(landscape, directions = 8,
                                   consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_core_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_p_core
#' @export
lsm_p_core.RasterBrick <- function(landscape, directions = 8,
                                   consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_core_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_p_core
#' @export
lsm_p_core.stars <- function(landscape, directions = 8,
                             consider_boundary = FALSE, edge_depth = 1) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_p_core_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

#' @name lsm_p_core
#' @export
lsm_p_core.list <- function(landscape, directions = 8,
                            consider_boundary = FALSE, edge_depth = 1) {

    result <- lapply(X = landscape,
                     FUN = lsm_p_core_calc,
                     directions = directions,
                     consider_boundary = consider_boundary,
                     edge_depth = edge_depth)

    dplyr::mutate(dplyr::bind_rows(result, .id = "layer"),
                  layer = as.integer(layer))
}

lsm_p_core_calc <- function(landscape, directions, consider_boundary, edge_depth) {

    landscape_labeled <- get_patches(landscape, directions = directions)

    core <- lapply(landscape_labeled, function(patches_class) {

        if(!isTRUE(consider_boundary)) {
            patches_class <- pad_raster(patches_class, pad_raster_value = NA,
                                        pad_raster_cells = 1,
                                        global = FALSE)
        }

        class_edge <- raster::boundaries(patches_class,
                                       directions = 4)

        cells_edge_patch <- table(factor(raster::values(patches_class)[raster::values(class_edge) == 1],
                                   levels = unique(raster::values(patches_class))))

        if(edge_depth > 1){
            for(i in seq_len(edge_depth - 1)){

                raster::values(class_edge)[raster::values(class_edge) == 1] <- NA

                class_edge <- raster::boundaries(class_edge,
                                               directions = 4)

                cells_edge_patch <- cells_edge_patch + table(factor(raster::values(patches_class)[raster::values(class_edge) == 1],
                                                              levels = unique(raster::values(patches_class))))
            }
        }

        cells_patch <- table(factor(raster::values(patches_class),
                                    levels = unique(raster::values(patches_class))))

        core_area <- (cells_patch - cells_edge_patch) * prod(raster::res(patches_class)) / 10000

        class <- sub("Class_", "", names(patches_class))

        tibble::tibble(class = class,
                       value = core_area)
    })

    core <- dplyr::bind_rows(core)

    tibble::tibble(
        level = "patch",
        class = as.integer(core$class),
        id = as.integer(seq_len(nrow(core))),
        metric = "core",
        value = as.double(core$value)
    )
}

