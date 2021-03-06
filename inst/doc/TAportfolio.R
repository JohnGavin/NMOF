### R code from vignette source 'TAportfolio.Rnw'

###################################################
### code chunk number 1: TAportfolio.Rnw:19-20
###################################################
options(continue = " ", digits = 5)


###################################################
### code chunk number 2: TAportfolio.Rnw:38-42
###################################################
require("NMOF")
resample <- function(x, ...)
    x[sample.int(length(x), ...)]
set.seed(112233)


###################################################
### code chunk number 3: TAportfolio.Rnw:73-84
###################################################
na <- dim(fundData)[2L]
ns <- dim(fundData)[1L]
winf <- 0.0; wsup <- 0.05
data <- list(R = t(fundData),
             RR = crossprod(fundData),
             na = na,
             ns = ns,
             eps = 0.5/100,
             winf = winf,
             wsup = wsup,
             resample = resample)


###################################################
### code chunk number 4: TAportfolio.Rnw:88-99
###################################################
neighbour <- function(w, data){
    eps <- runif(1L) * data$eps
    toSell <- w > data$winf
    toBuy  <- w < data$wsup
    i <- data$resample(which(toSell), size = 1L)
    j <- data$resample(which(toBuy),  size = 1L)
    eps <- min(w[i] - data$winf, data$wsup - w[j], eps)
    w[i] <- w[i] - eps
    w[j] <- w[j] + eps
    w
}


###################################################
### code chunk number 5: TAportfolio.Rnw:103-111
###################################################
OF1 <- function(w, data) {
    Rw <- crossprod(data$R, w)
    crossprod(Rw)
}
OF2 <- function(w, data) {
    aux <- crossprod(data$RR, w)
    crossprod(w, aux)
}


###################################################
### code chunk number 6: TAportfolio.Rnw:119-129
###################################################
w0 <- runif(na); w0 <- w0/sum(w0)

algo <- list(x0 = w0,
             neighbour = neighbour,
             nS = 2000L,
             nT = 10L,
             nD = 5000L,
             q = 0.20,
             printBar = FALSE,
             printDetail = FALSE)


###################################################
### code chunk number 7: TAportfolio.Rnw:132-134
###################################################
system.time(res <- TAopt(OF1,algo,data))
100 * sqrt(crossprod(fundData %*% res$xbest)/ns)


###################################################
### code chunk number 8: TAportfolio.Rnw:137-139
###################################################
system.time(res <- TAopt(OF2,algo,data))
100*sqrt(crossprod(fundData %*% res$xbest)/ns)


###################################################
### code chunk number 9: TAportfolio.Rnw:144-147
###################################################
min(res$xbest) ## should not be smaller than data$winf
max(res$xbest) ## should not be greater than data$wsup
sum(res$xbest) ## should be one


###################################################
### code chunk number 10: TAportfolio.Rnw:153-177
###################################################
if (require("quadprog", quietly = TRUE)) {
    covMatrix <- crossprod(fundData)
    A <- rep(1, na); a <- 1
    B <- rbind(-diag(na), diag(na))
    b <- rbind(array(-data$wsup, dim = c(na, 1L)),
               array( data$winf, dim = c(na, 1L)))
    system.time({
        result <- solve.QP(Dmat = covMatrix,
                           dvec = rep(0,na),
                           Amat = t(rbind(A,B)),
                           bvec = rbind(a,b),
                           meq = 1L)
    })
    wqp <- result$solution

    cat("Compare results...\n")
    cat("QP:", 100 * sqrt( crossprod(fundData %*% wqp)/ns ),"\n")
    cat("TA:", 100 * sqrt( crossprod(fundData %*% res$xbest)/ns ) ,"\n")

    cat("Check constraints ...\n")
    cat("min weight:", min(wqp), "\n")
    cat("max weight:", max(wqp), "\n")
    cat("sum of weights:", sum(wqp), "\n")
}


###################################################
### code chunk number 11: TAportfolio.Rnw:183-198
###################################################
neighbourU <- function(sol, data){
    wn <- sol$w
    toSell <- wn > data$winf
    toBuy  <- wn < data$wsup
    i <- data$resample(which(toSell), size = 1L)
    j <- data$resample(which(toBuy), size = 1L)
    eps <- runif(1) * data$eps
    eps <- min(wn[i] - data$winf, data$wsup - wn[j], eps)
    wn[i] <- wn[i] - eps
    wn[j] <- wn[j] + eps
    Rw <- sol$Rw + data$R[,c(i,j)] %*% c(-eps,eps)
    list(w = wn, Rw = Rw)
}
OF <- function(sol, data)
    crossprod(sol$Rw)


###################################################
### code chunk number 12: TAportfolio.Rnw:202-205
###################################################
data <- list(R = fundData, na = na, ns = ns,
             eps = 0.5/100, winf = winf, wsup = wsup,
             resample = resample)


###################################################
### code chunk number 13: TAportfolio.Rnw:209-221
###################################################
w0 <- runif(data$na); w0 <- w0/sum(w0)
x0 <- list(w = w0, Rw = fundData %*% w0)
algo <- list(x0 = x0,
             neighbour = neighbourU,
             nS = 2000L,
             nT = 10L,
             nD = 5000L,
             q = 0.20,
             printBar = FALSE,
             printDetail = FALSE)
system.time(res2 <- TAopt(OF, algo, data))
100*sqrt(crossprod(fundData %*% res2$xbest$w)/ns)


###################################################
### code chunk number 14: TAportfolio.Rnw:227-228
###################################################
fundData <- cbind(fundData, fundData[, 200L])


###################################################
### code chunk number 15: TAportfolio.Rnw:231-234
###################################################
dim(fundData)
qr(fundData)$rank
qr(cov(fundData))$rank


###################################################
### code chunk number 16: TAportfolio.Rnw:238-240
###################################################
if (require("quadprog", quietly = TRUE))
    wqp[200L]


###################################################
### code chunk number 17: TAportfolio.Rnw:243-250
###################################################
na <- dim(fundData)[2L]
ns <- dim(fundData)[1L]
winf <- 0.0; wsup <- 0.05
data <- list(R = fundData, na = na, ns = ns,
             eps = 0.5/100, winf = winf, wsup = wsup,
             resample = resample)



###################################################
### code chunk number 18: TAportfolio.Rnw:253-266
###################################################
if (require("quadprog", quietly = TRUE)) {
    covMatrix <- crossprod(fundData)
    A <- rep(1, na); a <- 1
    B <- rbind(-diag(na), diag(na))
    b <- rbind(array(-data$wsup, dim = c(na, 1L)),
               array( data$winf, dim = c(na, 1L)))
    cat(try(result <- solve.QP(Dmat = covMatrix,
                                 dvec = rep(0,na),
                                 Amat = t(rbind(A,B)),
                                 bvec = rbind(a,b),
                                 meq = 1L)
              ))
}


###################################################
### code chunk number 19: TAportfolio.Rnw:269-281
###################################################
w0 <- runif(data$na); w0 <- w0/sum(w0)
x0 <- list(w = w0, Rw = fundData %*% w0)
algo <- list(x0 = x0,
             neighbour = neighbourU,
             nS = 2000L,
             nT = 10L,
             nD = 5000L,
             q = 0.20,
             printBar = FALSE,
             printDetail = FALSE)
system.time(res3 <- TAopt(OF, algo, data))
100*sqrt(crossprod(fundData %*% res3$xbest$w)/ns)


###################################################
### code chunk number 20: TAportfolio.Rnw:284-285
###################################################
res3$xbest$w[200:201]


