### R code from vignette source 'DEnss.Rnw'

###################################################
### code chunk number 1: DEnss.Rnw:24-25
###################################################
options(continue = " ", digits = 5)


###################################################
### code chunk number 2: DEnss.Rnw:51-54
###################################################
require("NMOF")
nRuns <- 3L
set.seed(112233)


###################################################
### code chunk number 3: DEnss.Rnw:63-69
###################################################
tm <- c(c(1, 3, 6, 9)/12, 1:10)
betaTRUE <- c(6, 3, 8, 1)
yM <- NS(betaTRUE, tm)
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years", ylab = "yields in %")


###################################################
### code chunk number 4: DEnss.Rnw:80-87
###################################################
OF <- function(param, data) {
    y <- data$model(param, data$tm)
    maxdiff <- y - data$yM
    maxdiff <- max(abs(maxdiff))
    if (is.na(maxdiff)) maxdiff <- 1e10
    maxdiff
}


###################################################
### code chunk number 5: DEnss.Rnw:96-102
###################################################
data <- list(yM = yM,
             tm = tm,
          model = NS,
             ww = 0.1,
            min = c( 0,-15,-30, 0),
            max = c(15, 30, 30,10))


###################################################
### code chunk number 6: DEnss.Rnw:114-118
###################################################
param1 <- betaTRUE         ## the solution...
OF(param1, data)           ## ...gives 0
param2 <- c(5.7, 3, 8, 2)  ## anything else
OF(param2, data)           ## ... gives a postive number


###################################################
### code chunk number 7: DEnss.Rnw:122-131
###################################################
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years", ylab = "yields in %")
lines(tm, NS(param1, tm), col = "blue")
lines(tm, NS(param2, tm), col = "red")
legend(x = "topright",
       legend = c("true yields", "param1", "param2"),
       col = c("black", "blue", "red"),
       pch = c(1, NA, NA), lty = c(0, 1, 1))


###################################################
### code chunk number 8: DEnss.Rnw:136-151
###################################################
penalty <- function(mP, data) {
    minV <- data$min
    maxV <- data$max
    ww <- data$ww
    ## if larger than maxV, element in A is positiv
    A <- mP - as.vector(maxV)
    A <- A + abs(A)
    ## if smaller than minV, element in B is positiv
    B <- as.vector(minV) - mP
    B <- B + abs(B)
    ## beta 1 + beta2 > 0
    C <- ww*((mP[1L, ] + mP[2L, ]) - abs(mP[1L, ] + mP[2L, ]))
    A <- ww * colSums(A + B) - C
    A
}


###################################################
### code chunk number 9: DEnss.Rnw:158-165
###################################################
param1 <- c( 6, 3, 8, -1)
param2 <- c( 6, 3, 8,  1)
param3 <- c(-1, 3, 8,  1)

mP <- cbind(param1,param2,param3)
rownames(mP) <- c("b1","b2","b3","lambda")
mP


###################################################
### code chunk number 10: DEnss.Rnw:171-172
###################################################
penalty(mP,data)


###################################################
### code chunk number 11: DEnss.Rnw:176-178
###################################################
data$ww <- 0.5
penalty(mP,data)


###################################################
### code chunk number 12: DEnss.Rnw:182-188
###################################################
param1 <- c( 6, 3, 8, 1)
param2 <- c( 6, 3, 8, 1)
param3 <- c( 2, 3, 8, 1)
mP <- cbind(param1, param2, param3)
rownames(mP) <- c("b1","b2","b3","lambda")
penalty(mP, data)


###################################################
### code chunk number 13: DEnss.Rnw:197-209
###################################################
algo <- list(nP = 100L,   ## population size
             nG = 500L,   ## number of generations
              F = 0.50,   ## step size
             CR = 0.99,   ## prob. of crossover
            min = c( 0,-15,-30, 0),
            max = c(15, 30, 30,10),
            pen = penalty,
         repair = NULL,
         loopOF = TRUE,   ## loop over popuation? yes
        loopPen = FALSE,  ## loop over popuation? no
     loopRepair = TRUE,   ## loop over popuation? yes
       printBar = FALSE)


###################################################
### code chunk number 14: DEnss.Rnw:214-215
###################################################
sol <- DEopt(OF = OF, algo = algo, data = data)


###################################################
### code chunk number 15: DEnss.Rnw:221-223
###################################################
max( abs(data$model(sol$xbest, tm) - data$model(betaTRUE, tm)) )
sol$OFvalue


###################################################
### code chunk number 16: DEnss.Rnw:232-238
###################################################
s0 <- algo$min + (algo$max - algo$min) * runif(length(algo$min))
sol2 <- nlminb(s0, OF, data = data,
                           lower = data$min,
                           upper = data$max,
                           control = list(eval.max = 50000L,
                                          iter.max = 50000L))


###################################################
### code chunk number 17: DEnss.Rnw:243-245
###################################################
max( abs(data$model(sol2$par, tm) - data$model(betaTRUE,tm)) )
sol2$objective


###################################################
### code chunk number 18: DEnss.Rnw:258-279
###################################################
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years",
             ylab = "yields in %")
algo$printDetail <- FALSE
for (i in seq_len(nRuns)) {
    sol <- DEopt(OF = OF, algo = algo, data = data)
    lines(tm, data$model(sol$xbest,tm), col = "blue")
    s0 <- algo$min + (algo$max-algo$min) * runif(length(algo$min))
    sol2 <- nlminb(s0, OF, data = data,
                           lower = data$min,
                           upper = data$max,
                           control = list(eval.max = 50000L,
                                          iter.max = 50000L))

    lines(tm,data$model(sol2$par,tm), col = "darkgreen", lty = 2)
}

legend(x = "topright", legend = c("true yields", "DE", "nlminb"),
       col = c("black","blue","darkgreen"),
       pch = c(1, NA, NA), lty = c(0, 1, 2))


###################################################
### code chunk number 19: DEnss.Rnw:291-298
###################################################
tm <- seq(1, 10, length.out = 100)   ## 1 to 10 years
betaTRUE <- c(3, -2, -8, 1.5)        ## 'true' parameters
yM <- NS(betaTRUE, tm)
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years", ylab = "yields in %")
abline(h = 0)


###################################################
### code chunk number 20: DEnss.Rnw:305-310
###################################################
penalty2 <- function(param, data) {
    y <- data$model(param, data$tm)
    maxdiff <- abs(y - abs(y))
    sum(maxdiff) * data$ww
}


###################################################
### code chunk number 21: DEnss.Rnw:313-314
###################################################
penalty2(c(3, -2, -8, 1.5),data)


###################################################
### code chunk number 22: DEnss.Rnw:319-330
###################################################
OFa <- function(param,data) {
    y <- data$model(param,data$tm)
    aux <- y - data$yM
    res <- max(abs(aux))
    ## compute the penalty
    aux <- y - abs(y) ## aux == zero for nonnegative y
    aux <- -sum(aux) * data$ww
    res <- res + aux
    if (is.na(res)) res <- 1e10
    res
}


###################################################
### code chunk number 23: DEnss.Rnw:335-345
###################################################
algo$pen <- NULL; data$yM <- yM; data$tm <- tm
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years", ylab = "yields in %")
abline(h = 0)
sol <- DEopt(OF = OFa, algo = algo, data = data)
lines(tm,data$model(sol$xbest,tm), col = "blue")
legend(x = "topleft", legend = c("true yields", "DE (constrained)"),
       col = c("black", "blue"),
       pch = c(1, NA, NA), lty = c(0, 1, 2))


###################################################
### code chunk number 24: DEnss.Rnw:355-358
###################################################
tm <- c(c(1, 3, 6, 9)/12, 1:10)
betaTRUE <- c(5,-2,5,-5,1,6)
yM <- NSS(betaTRUE, tm)


###################################################
### code chunk number 25: DEnss.Rnw:363-383
###################################################
data <- list(yM = yM,
             tm = tm,
          model = NSS,
            min = c( 0,-15,-30,-30,  0,5),
            max = c(15, 30, 30, 30,  5,  10),
             ww = 1)

algo <- list(nP = 100L,
             nG = 500L,
              F = 0.50,
             CR = 0.99,
            min = c( 0,-15,-30,-30,  0,5),
            max = c(15, 30, 30, 30,  5,  10),
            pen = penalty,
         repair = NULL,
         loopOF = TRUE,
        loopPen = FALSE,
     loopRepair = TRUE,
       printBar = FALSE,
    printDetail = FALSE)


###################################################
### code chunk number 26: DEnss.Rnw:388-391
###################################################
sol <- DEopt(OF = OF, algo = algo, data = data)
max( abs(data$model(sol$xbest, tm) - data$model(betaTRUE, tm)) )
sol$OFvalue


###################################################
### code chunk number 27: DEnss.Rnw:395-403
###################################################
s0 <- algo$min + (algo$max - algo$min) * runif(length(algo$min))
sol2 <- nlminb(s0,OF,data = data,
                           lower = data$min,
                           upper = data$max,
                         control = list(eval.max = 50000L,
                                        iter.max = 50000L))
max( abs(data$model(sol2$par, tm) - data$model(betaTRUE, tm)) )
sol2$objective


###################################################
### code chunk number 28: DEnss.Rnw:409-428
###################################################
par(ps = 11, bty = "n", las = 1, tck = 0.01,
    mgp = c(3, 0.2, 0), mar = c(4, 4, 1, 1))
plot(tm, yM, xlab = "maturities in years", ylab = "yields in %")
for (i in seq_len(nRuns)) {
    sol <- DEopt(OF = OF, algo = algo, data = data)
    lines(tm, data$model(sol$xbest,tm), col = "blue")
    s0 <- algo$min + (algo$max - algo$min) * runif(length(algo$min))
    sol2 <- nlminb(s0, OF, data = data,
                           lower = data$min,
                           upper = data$max,
                           control = list(eval.max = 50000L,
                                          iter.max = 50000L))

    lines(tm, data$model(sol2$par,tm), col = "darkgreen", lty = 2)
}

legend(x = "topright", legend = c("true yields", "DE", "nlminb"),
       col = c("black","blue","darkgreen"),
       pch = c(1,NA,NA), lty = c(0,1,2), bg = "white")


###################################################
### code chunk number 29: DEnss.Rnw:439-441 (eval = FALSE)
###################################################
## whereToLook <- system.file("NMOFex/NMOFman.R", package = "NMOF")
## file.show(whereToLook, title = "NMOF examples")


###################################################
### code chunk number 30: DEnss.Rnw:454-456 (eval = FALSE)
###################################################
## whereToLook <- system.file("NMOFex/NMOFman.R", package = "NMOF")
## file.show(whereToLook, title = "NMOF examples")


