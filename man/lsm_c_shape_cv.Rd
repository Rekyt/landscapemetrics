% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lsm_c_shape_cv.R
\name{lsm_c_shape_cv}
\alias{lsm_c_shape_cv}
\alias{lsm_c_shape_cv.RasterLayer}
\alias{lsm_c_shape_cv.RasterStack}
\alias{lsm_c_shape_cv.RasterBrick}
\alias{lsm_c_shape_cv.stars}
\alias{lsm_c_shape_cv.list}
\title{SHAPE_CV (class level)}
\usage{
lsm_c_shape_cv(landscape, directions)

\method{lsm_c_shape_cv}{RasterLayer}(landscape, directions = 8)

\method{lsm_c_shape_cv}{RasterStack}(landscape, directions = 8)

\method{lsm_c_shape_cv}{RasterBrick}(landscape, directions = 8)

\method{lsm_c_shape_cv}{stars}(landscape, directions = 8)

\method{lsm_c_shape_cv}{list}(landscape, directions = 8)
}
\arguments{
\item{landscape}{Raster* Layer, Stack, Brick or a list of rasterLayers.}

\item{directions}{The number of directions in which patches should be
connected: 4 (rook's case) or 8 (queen's case).}
}
\value{
tibble
}
\description{
Covariance of variation shape index (Shape metric)
}
\details{
\deqn{SHAPE_{CV} = cv(SHAPE[patch_{ij}])}
where \eqn{SHAPE[patch_{ij}]} is the shape index of each patch.

SHAPE_CV is a 'Shape metric'. Each class is summarised as the Coefficient of variation
of each patch belonging to class i. SHAPE describes the ratio between the actual perimeter
of the patch and the hypothetical minimum perimeter of the patch. The minimum perimeter
equals the perimeter if the patch would be maximally compact.

\subsection{Units}{None}
\subsection{Range}{SHAPE_CV >= 0}
\subsection{Behaviour}{Equals SHAPE_CV = 0 if all patches have an identical shape index.
Increases, without limit, as the variation of the shape index increases.}
}
\examples{
lsm_c_shape_cv(landscape)

}
\references{
McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
Program for Categorical and Continuous Maps. Computer software program produced by
the authors at the University of Massachusetts, Amherst. Available at the following
web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html

Patton, D. R. 1975. A diversity index for quantifying habitat "edge".
Wildl. Soc.Bull. 3:171-173.
}
\seealso{
\code{\link{lsm_p_shape}},
\code{\link{cv}}, \cr
\code{\link{lsm_c_shape_mn}},
\code{\link{lsm_c_shape_sd}}, \cr
\code{\link{lsm_l_shape_mn}},
\code{\link{lsm_l_shape_sd}},
\code{\link{lsm_l_shape_cv}}
}
