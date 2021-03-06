#' construct_buffer
#'
#' @description Internal function to construct plot area around points
#'
#' @param points SpatialPoints or 2-column matrix with coordinates of sample points
#' @param shape String specifying plot shape. Either "circle" or "square"
#' @param size Size of sample plot. Equals the radius for circles or the
#' side-length for squares in mapunits
#'
#' @return
#' SpatialPolygons
#'
#' @examples
#' points <- matrix(c(10, 5, 25, 15, 5, 25), ncol = 2, byrow = TRUE)
#' construct_buffer(points = points, shape = "square", size = 5)
#'
#' @aliases construct_buffer
#' @rdname construct_buffer
#'
#' @keywords internal
#'
#' @export
construct_buffer <- function(points, shape, size) UseMethod("construct_buffer")

#' @name construct_buffer
#' @export
construct_buffer.matrix <- function(points, shape, size) {

    if(shape == "circle") {

        circle_points_x <- sin(seq(0, 2 * pi, length.out = 100)) * size
        circle_points_y <- cos(seq(0, 2 * pi, length.out = 100)) * size

        x_circle <- outer(circle_points_x,  points[, 1], `+`)
        y_circle <- outer(circle_points_y,  points[, 2], `+`)

        sample_plots_coords <- cbind(matrix(x_circle, ncol = 1),
                                     matrix(y_circle, ncol = 1),
                                     rep(1:nrow(points), each = 100))

        sample_plots_coords_split <- split(sample_plots_coords[, -3], sample_plots_coords[, 3])

        sample_plots <- lapply(X = sample_plots_coords_split, FUN = function(x) {
            sp::Polygon(cbind(x[1:100], x[101:200]))
        })

        sample_plots <- sp::SpatialPolygons(lapply(X = seq_along(sample_plots), FUN = function(y) {
            sp::Polygons(list(sample_plots[[y]]), ID = y)
        }))
    }

    else if (shape == "square") {

        sample_plots_coords <- cbind(
            matrix(
                c(points[, 1] - size / 2,
                  points[, 1] - size / 2,
                  points[, 1] + size / 2,
                  points[, 1] + size / 2),
                ncol = 1),

            matrix(
                c(points[, 2] - size / 2,
                  points[, 2] + size / 2,
                  points[, 2] + size / 2,
                  points[, 2] - size / 2),
                ncol = 1),
            rep(1:nrow(points), times = 4)
        )

        sample_plots_coords_split <- split(sample_plots_coords[, -3],
                                           sample_plots_coords[, 3])

        sample_plots <- lapply(X = sample_plots_coords_split, FUN = function(x) {
            sp::Polygon(cbind(x[1:4], x[5:8]))
        })

        sample_plots <- sp::SpatialPolygons(lapply(X = seq_along(sample_plots), FUN = function(y) {
            sp::Polygons(list(sample_plots[[y]]), ID = y)
        }))
    }

    else{
        stop(paste0("Shape option ", shape, " unkown"), call. = FALSE)
    }

    return(sample_plots)
}

#' @name construct_buffer
#' @export
construct_buffer.SpatialPoints <- function(points, shape, size) {
    points <- matrix(sp::coordinates(points), ncol = 2)
    construct_buffer(points, shape, size)
}

#' @name construct_buffer
#' @export
construct_buffer.SpatialPointsDataFrame <- function(points, shape, size) {
    points <- matrix(sp::coordinates(points), ncol = 2)
    construct_buffer(points, shape, size)
}

#' @name construct_buffer
#' @export
construct_buffer.MULTIPOINT <- function(points, shape, size) {
    points <- matrix(sf::st_coordinates(points)[, 1:2], ncol = 2)
    construct_buffer(points, shape, size)
}

#' @name construct_buffer
#' @export
construct_buffer.POINT <- function(points, shape, size) {
    points <- matrix(sf::st_coordinates(points)[, 1:2], ncol = 2)
    construct_buffer(points, shape, size)
}

#' @name construct_buffer
#' @export
construct_buffer.sf <- function(points, shape, size) {
    if(all(sf::st_geometry_type(points) %in% c("POINT", "MULTIPOINT"))){
        points <- matrix(sf::st_coordinates(points)[, 1:2], ncol = 2)
        construct_buffer(points, shape, size)
    }

    else{stop("Only POINT or MULTIPOINT features supported!!11!!1!!")}
}

#' @name construct_buffer
#' @export
construct_buffer.sfc <- function(points, shape, size) {
    if(all(sf::st_geometry_type(points) %in% c("POINT", "MULTIPOINT"))){
        points <- matrix(sf::st_coordinates(points)[, 1:2], ncol = 2)
        construct_buffer(points, shape, size)
    }

    else{stop("Only POINT or MULTIPOINT features supported!!11!!1!!")}
}
