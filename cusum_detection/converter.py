import pandas as pd

df = pd.read_csv("csv_files/temperatures.csv")

#to integers
num_cols = df.select_dtypes(include="number").columns

df[num_cols] = df[num_cols] * 100

df[num_cols] = df[num_cols].astype(int)
for col in num_cols:
    new_df = df[[col]]
    new_df.to_csv(f"csv_files/binary_temperatures_{col.strip()}.csv", index = False, header = False)

