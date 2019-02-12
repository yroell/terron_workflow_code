##### install and load libraries #####

# install libraries not yet on computer
list.of.packages = c("raster", "cluster", "e1071", "rgr", "stringr", "plyr", "devtools")
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) {
  install.packages(new.packages)
}
fuzme.package = "fuzme"
new.fuzme = fuzme.package[!(fuzme.package %in% installed.packages()[,"Package"])]
if (length(new.fuzme)) {
  library(devtools)
  install_bitbucket("brendo1001/fuzme/rPackage/fuzme")
}

# load libraries
library(raster)
library(cluster)
library(e1071)
library(rgr)
library(stringr)
library(plyr)
library(fuzme)


##### start of defining functions #####

print_messages = function(log_file, messages) {
  cat(messages, file = log_file, sep = "\n", append = TRUE)
  cat(messages, sep = "\n")
}


optimal_cluster = function(data_k, n.lev) {
  kdata = data_k
  wss <- rnorm(10); wss_per = 0
  wss <- (nrow(kdata)-1)*sum(apply(kdata,2,var))
  for (i in 2:n.lev) {
    kcluster = kmeans(kdata, centers = i, iter.max = 100, nstart = 1)
    wss[i] = sum(kcluster$withinss)}
  
  k.rand <- function(x){
    km.rand <- apply(x,2,sample)
    rand.wss <- as.matrix(dim(x)[1]-1)*sum(apply(km.rand,2,var))
    for (i in 2:n.lev){
      rand.wss[i] <- sum(kmeans(km.rand, nstart = 1, centers=i)$withinss)}
    rand.wss <- as.matrix(rand.wss)
    return(rand.wss)}
  rand.mat <- matrix(0,n.lev,10)
  k.1 <- function(x) { 
    for (i in 1:10) {
      r.mat <- as.matrix(suppressWarnings(k.rand(kdata)))
      rand.mat[,i] <- r.mat}
    return(rand.mat)}
  rand.mat <- k.1(kdata)
  
  r.sse <- matrix(0,dim(rand.mat)[1],dim(rand.mat)[2])
  wss.1 <- as.matrix(wss)
  for (i in 1:dim(r.sse)[2]) {
    r.temp <- abs(rand.mat[,i]-wss.1[,1])
    r.sse[,i] <- r.temp}
  r.sse.m <- apply(r.sse,1,mean)
  return(match(max(r.sse.m),r.sse.m))
}


fuzme_iteration = function(data_fuzzy, cluster_num, num_try) {
  nclass = cluster_num     # number of classes
  data = data_fuzzy     # data frame to use with no missing data
  phi = 1.2     # fuzzy exponent value; 1 = hard clustering, > 1 increases fuzziness clustering
  maxiter = 1000     # max iterations per run
  distype = 3     # distance metric; 1 = Euclidean, 2 = Diagonal, 3 = Mahalanobis
  toldif = 1     # fuzzy algorithm tolerance; closer to 0 = lower tolerance (takes longer)
  scatter = 0.5     # determing inital memberships to centroids; higher the number = more scatter
  ntry = num_try     # number of runs to optimize clustering data
  verbose = 1     # display results; 1 = display processing, 0 = no display
  
  results = runFuzme(nclass,data,phi,maxiter,distype,toldif,scatter,ntry,verbose)
  
  member = as.data.frame(results$membership)
  member$highclass = apply(member[,1:nclass],1,max)
  member$hardclass = colnames(member[,1:nclass])[apply(member[,1:nclass],1,which.max)]
  member$terron = as.numeric(str_sub(member$hardclass, start = 2, end = -1))
  merge = cbind(data, member[,c("terron", "highclass")])
  return(merge)
}