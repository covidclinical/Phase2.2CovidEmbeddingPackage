# Phase2.1CovidEmbedding

R code to prepare the input data for the Phase2.2 covid cooccurrence and embedding.

# Non-Docker Users
## 1. Make sure your R is upgraded to 4.0.2

## 2. Always RESTART your R session before installing or re-installing the package!

## 3. Run the following scripts in R:

```
devtools::install_github("https://github.com/covidclinical/Phase2.2CovidEmbeddingRPackage", subdir="FourCePhase2.2CovidEmbedding", upgrade=FALSE, force=T)
currSiteId = "MGB" ## change to your siteid
dir.input="/Users/chuanhong/Documents/Input" ## change to your input directory
dir.output="/Users/chuanhong/Documents/Output" ## change to your output directory
library(FourCePhase2.2CovidEmbedding)
dat.cooccur.input=FourCePhase2.2CovidEmbedding::runAnalysis_nodocker(currSiteId, dir.input)
```

## 4. Do NOT submit your data


