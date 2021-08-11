rm(list=ls())
remove.packages("FourCePhase2.2CovidEmbedding")
devtools::install_github("https://github.com/covidclinical/Phase2.2CovidEmbeddingRPackage", subdir="FourCePhase2.2CovidEmbedding", upgrade=FALSE, force=T)
currSiteId = "MGB" ## change to your siteid
dir.input="/Users/chuanhong/Documents/Input"
dir.output="/Users/chuanhong/Documents/Output"
library(FourCePhase2.2CovidEmbedding)
dat.cooccur.input=FourCePhase2.2CovidEmbedding::runAnalysis_nodocker(currSiteId, dir.input)
