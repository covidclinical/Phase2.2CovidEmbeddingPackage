import pandas as pd
import numpy as np
df = pd.read_csv("test.csv", names=["PatientOrder", "NumDays", "WordIndex","window"])

df["NumDays"] = df["NumDays"].astype(np.int32)
df["WordIndex"] = df["WordIndex"].astype(np.int32)
df["window"] = df["window"].astype(np.int32)
df["PatientOrder"] = df["PatientOrder"].astype(np.int64)

print(df)
df.to_parquet("inp_test.parquet")


