#' @param lambda parámetro lambda de suavizado.
#'
#' @rdname metodos_interpolacion
#' @export
# Código adaptado de https://bitbucket.org/brendo1001/ithir/src/master/pkg/R/ea_spline.R
interpolar_spline <- function(lambda = 0.1) {
  force(lambda)

  function(superior, inferior, obs, horizontes) {
    u <- superior
    v <- inferior
    d <- horizontes
    n <- length(superior)
    mxd <- max(d)
    y <- NULL

    vhigh <- 1000
    vlow <- 0

    ## ESTIMATION OF SPLINE PARAMETERS
    np1 <- n+1  # number of interval boundaries
    nm1 <- n-1
    delta <- v-u  # depths of each layer
    del <- c(u[2:n],u[n])-v   # del is (u1-v0,u2-v1, ...)

    ## create the (n-1)x(n-1) matrix r; first create r with 1's on the diagonal and upper diagonal, and 0's elsewhere
    r <- diag(1, nrow = n-1, ncol = n-1)
    r <- cbind(0, r[, seq_len(n-2)]) + r

    ## then create a diagonal matrix d2 of differences to premultiply the current r
    d2 <- diag(delta[-1], nrow = n-1, ncol = n-1)


    ## then premultiply and add the transpose; this gives half of r
    r <- d2 %*% r
    r <- r + t(r)

    ## then create a new diagonal matrix for differences to add to the diagonal
    d1 <- diag(delta[-length(delta)], nrow = n-1, ncol = n-1)

    d3 <- diag(del[-length(delta)], nrow = n-1, ncol = n-1)

    r <- r+2*d1 + 6*d3

    ## create the (n-1)xn matrix q
    q <- diag(-1, nrow = n-1, ncol = n)
    q <- q + cbind(0, diag(1, nrow = n-1, ncol= n-1))


    dim.mat <- q

    ## inverse of r
    rinv <- try(solve(r), TRUE)

    # if rinv worked

    ## identity matrix i
    ind <- diag(1, nrow = n, ncol = n)

    ## create the matrix coefficent z
    pr.mat <- matrix(6*n*lambda, ncol = nm1, nrow = n)
    fdub <- pr.mat*t(dim.mat)%*%rinv

    z <- fdub%*%dim.mat + ind

    ## solve for the fitted layer means
    sbar <- solve(z, obs)


    ## calculate the fitted value at the knots
    b <- 6*rinv%*%dim.mat%*% sbar
    b0 <- rbind(0, b) # add a row to top = 0
    b1 <- rbind(b, 0) # add a row to bottom = 0
    gamma <- (b1 - b0) / t(t(2*delta))
    alfa <- sbar-b0 * t(t(delta)) / 2-gamma * t(t(delta))^2/3


    ## END ESTIMATION OF SPLINE PARAMETERS
    ###############################################################################################################################################################


    ## fit the spline
    xfit <- matrix(seq_len(mxd), nrow = 1) ## spline will be interpolated onto these depths (1cm res)
    nj <- max(v)

    if (nj > mxd) {
      nj <- mxd
    }
    yfit <- xfit

    for (k in seq_len(nj)) {
      xd <- xfit[k]

      if (xd < u[1]) {
        p <- alfa[1]
      } else if (xd < nj) {
        layer <- which(xd >= u & xd < v)
        if (length(layer) > 0) {
          # We are inside a layer
          p <- alfa[layer] + b0[layer]*(xd - u[layer]) + gamma[layer]*(xd - u[layer])^2
        } else {
          # We are between layers
          layer <- which(xd >= v & xd < data.table::shift(u, -1))
          phi <- alfa[layer + 1] - b1[layer]*(u[layer + 1] - v[layer])
          p <- phi + b1[layer]*(xd - v[layer])
        }
      } else {
        p <- NA
      }
      if (length(p) != 1) stop("!!")

      yfit[k] <- p
    }


    if (nj < mxd) {
      yfit[,(nj+1):mxd] <- NA
    }

    yfit[which(yfit > vhigh)] <- vhigh
    yfit[which(yfit < vlow)] <- vlow

    ## Averages of the spline at specified depths
    nd <- length(d) - 1  # number of depth intervals
    dl <- d + 1     #  increase d by 1

    D <- data.table::data.table(x = as.vector(xfit),
                                y = as.vector(yfit))

    D <- D[, .(valor = mean(y, na.rm = TRUE)), by = cut(xfit, breaks = d)]
    D[, c("profundidad_superior", "profundidad_inferior") := list(as.vector(d)[-length(d)],
                                    as.vector(d)[-1])]
    D[, cut := NULL]
    return(D[])

  }
}


