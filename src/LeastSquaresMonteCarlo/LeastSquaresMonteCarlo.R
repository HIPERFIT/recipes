##
## Copyright 2016, HIPERFIT, University of Copenhagen
## Contributers: Rolf Poulsen, Martin Elsman
## MIT License
##

##
## Longstaff and Schwartz American option pricing based on linear regression
##

lsmc <- function (S, payoffFun, r) {
  paths <- dim(S)[1]
  steps <- dim(S)[2]
  disc <- exp(r*(-(1:(steps-1))))
  P <- matrix( 0, nrow = paths, ncol = steps)

  # First Cashflow at T is done outside the loop
  for (j in 1:paths) {
     P[j,steps] <- payoffFun(S[j,steps])
  }

  #Now do LSM within a loop
  for (h in (steps-1):2) {
    pick <- sapply(S[,h], function(s) { payoffFun(s) > 0 })
    pickedpaths <- (1:paths)[pick]
    Y <- sapply(pickedpaths,function(j){sum(disc[1:(steps-h)]*P[j,(h+1):steps])})
    dummy <- S[pick,h]
    X <- cbind (rep(1,length(pickedpaths)),dummy,dummy^2) # slow!
    b <- solve(t(X)%*%X)%*%t(X)%*%Y

    for (j in pickedpaths){ 
      payoff <- payoffFun(S[j,h])
      if (c(1,S[j,h],S[j,h]^2)%*%b < payoff) { 
        P[j,h] <- payoff
        P[j,(h+1):steps] <- 0
      }
    }
  }
  Z <- sapply(1:paths,function(j){sum(disc*P[j,2:steps])})
  mean(Z)
}

# Paper Example 1
EXAMPLE <- matrix( c(1,1.09,1.08,1.34,1,1.16,1.26,1.54,1,1.22,1.07,1.03,1,0.93,0.97,0.92,1,1.11,1.56,1.52,1,0.76,0.77,0.90,1,0.92,0.84,1.01,1,0.88,1.22,1.34), nrow=8, ncol=4, byrow=TRUE)
strike <- 1.1
payoffFun <- function(s) { max(strike-s,0) }
rate <- 0.06
res <- lsmc(EXAMPLE, payoffFun, rate)

# Print 0.1144343
print(res)
