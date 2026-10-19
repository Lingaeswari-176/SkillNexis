import pandas as pd

df = pd.read_csv("StudentsPerformance.csv")
print("Dataset shape:", df.shape)
print("\nMissing values before cleaning:")
print(df.isnull().sum())

clean_df = df.copy()
numeric_cols = clean_df.select_dtypes(include="number").columns
categorical_cols = clean_df.select_dtypes(exclude="number").columns

for col in numeric_cols:
    if clean_df[col].isnull().any():
        clean_df[col] = clean_df[col].fillna(clean_df[col].median())

for col in categorical_cols:
    if clean_df[col].isnull().any():
        mode_values = clean_df[col].mode()
        if not mode_values.empty:
            clean_df[col] = clean_df[col].fillna(mode_values.iloc[0])

score_cols = ["math score", "reading score", "writing score"]
summary = pd.DataFrame({
    "Average": clean_df[score_cols].mean(),
    "Minimum": clean_df[score_cols].min(),
    "Maximum": clean_df[score_cols].max()
}).round(2)

print("\nScore summary:")
print(summary)
print("\nOverall statistics:")
print(clean_df[score_cols].describe().round(2))

clean_df.to_csv("StudentsPerformance_Cleaned.csv", index=False)
summary.to_csv("Student_Score_Summary.csv")
print("\nSaved cleaned data and score summary.")
