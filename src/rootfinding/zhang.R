# Copyright 2016, Martin Elsman, MIT-license
#
# zhang : (real -> real) -> real * real -> real * real -> ((real*real)*int) option
#
# [rootFindZhang f precision (a,b)] returns SOME((v,fv),i) if |f(v)|
# <= precision and a <= v <= b with fv = f(v). The returned integer i
# denotes the number of iterations in Zhang's method [2], which is a
# simplification of Brent's method [1]. Returns NONE if the signs of f a
# and f b are not opposite (assuming f is continuous). Raises Fail if
# Zhang's method iterates more than 100 times (if perhaps, f is not
# contionuous).
#
# [1] R. P. Brent An algorithm with guaranteed convergence for finding
#     a zero for a function. The Computer Journal. Volume (14), Number
#     (4). Pages 422-425. 1971.
#
# [2] Zhengqiu Zhang. An Improvement to the Brent's
#     Method. International Journal of Experimental Algorithms (IJEA),
#     Volume (2), Issue (1), 2011.

# -----------------------------
# Library of list functions
# -----------------------------

foldl <- function (f,a,xs) { Reduce(f, xs, a, right = FALSE, accumulate = FALSE) }

foldli <- function(f,a,xs) {
  res <- foldl (function (p,x) { list(p[[1]]+1, f (p[[1]],x,p[[2]])) }, list(0,a), xs)
  res[[2]]
}

# -----------------------------
# Zhang's root finding method
# -----------------------------

secantOnly <- FALSE
zhang <- function(f, xtol, ftol, a, b) {
  fa <- f(a); fb <- f(b)
  i <- 2
  while (TRUE) {
    if (fa * fb >= 0) { stop("root not bracketed") }
    if (abs(b-a) <= xtol) { break }
    if (i > 100) { stop("100 iterations reached") }
    c <- 0.5*(a+b)
    fc <- f(c)
    i <- i + 1
    if (abs(fc) <= ftol) {
      b <- c; fb <- fc; break
    }
    if (secantOnly) {
      s <- (b - (fb*(b-a)/(fb-fa)))
    } else {
      s <- if ((fa != fc) & (fb != fb)) {    # inverse quadratic interpolation
	     ((a*fb*fc)/((fa-fb)*(fa-fc)))+
	     ((b*fa*fc)/((fb-fa)*(fb-fc)))+
	     ((c*fa*fb)/((fc-fa)*(fc-fb)))
	   } else {                          # secant rule
	     (b - (fb*(b-a)/(fb-fa)))
	   }
    }
    fs <- f(s)
    i <- i + 1
    if (abs(fs) <= ftol) { 
      b <- s; fb <- fs; break 
    }
    if (c < s) {                           # swap c and s
      t <- s; ft <- fs
      s <- c; fs <- fc
      c <- t; fc <- ft
    }
    if (fc * fs < 0) {
      a <- s; fa <- fs
      b <- c; fb <- fc
    } else if (fs * fb < 0) {
      a <- c; fa <- fc
    } else {
      b <- s; fb <- fs
    }
  }
  list(b,fb,i)
}

# -----------------------------
# Test cases
# -----------------------------

tol <- 0.0001

res <- zhang(function(x) x^2 - 2, tol, tol, 0, 5)


# --------------------------------
# Internal Rate of Return Example
# --------------------------------

npvCashFlows <- function(irr, cflows) {
  foldli (function(m,f,npv) { npv + f / ((1+irr)^m) }, 0, cflows)
}

calcIRR <- function (cflows,tol) {
  npv <- function (irr) { npvCashFlows(irr, cflows) }
  zhang(npv,tol,tol,-0.8,0.8)
}

cflows <- list(-1000,250,250,250,250,250)

res2 <- calcIRR(cflows,tol)


# -------------------------------------
# Root of function f(x) = (x+3)(x-1)^2
# -------------------------------------

f <- function(x) ((x+3)*(x-1)^2)

res3 <- zhang(f, tol, tol, -4, 4/3) 

zhangIterOverTol <- function(tol) { 
  res <- zhang(f,tol,tol,-4,4/3) 
  res[[3]]
}

tols <- c(0.0005,0.00001,0.000005,0.0000001,0.0000005,0.00000001,0.00000005,0.000000001)

plotfun <- function (f) {
  plot(mapply(f,tols),tols, xlab="Function Evaluations", ylab="Tolerance", log="y")
}

#plotfun(zhangIterOverTol)

plotfun(function(tol) { res <- calcIRR(cflows,tol) 
                        res[[3]] })
