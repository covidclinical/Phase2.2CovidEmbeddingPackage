# 1. Prepare the input data for cooccurrence.
# 1.1. Run the R package

R code to prepare the input data for the Phase2.2 covid cooccurrence and embedding.

## Non-Docker Users
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

# 1.2. Convert the data to .parquet

In the terminal, run the following Python code to read the data created using the R package and convert it to the .parquet format required for the cooccurrence tool.

```
module load anaconda/3-5.0.1
pip install --user pandas
pip install --user pyarrow
python
(ctrl+D to quit)

##### Python
import pandas as pd
import pyarrow as pa
import numpy as np

colnames=[1,2,3]
df = pd.read_csv('embeddingphase22.csv',header=None)
del df[0]
df=df.iloc[1:]
df['window']= np.full(df.shape[0], 30)
df2=df.astype(np.int32)
df2[1]=df2[1].astype(np.int64)
df2.columns=['PatientOrder', 'NumDays', 'WordIndex', 'window' ]
df2.to_parquet('data_sort_out.parquet')
```

# 2. Run cooccurrence

Please use the attached yaml file to create your environment. It includes the packages necessary to run the tool.

To create the conda environment, download the yml file to your machine and run the following terminal command :
```
conda env create -f cooccurrence_env.yml
```

A conda environment called coo_env will be created. In the next steps, go to the coocurreneMatrix folder and run :
```
conda activate coo_env
mkdir build
cd build
cmake ..
make -j 5
```

The tool will be created in the directory /coocurreneMatrix/bin/. To run the tool : 
```
./orderedPairsBefore out.parquet 2 input.parquet
./orderedPairsSameDay out.parquet 2 input.parquet
```


