import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the dataset (change the filename if needed)
df = pd.read_excel("data.xlsx")  # use pd.read_csv("data.csv") for a CSV file

# 1. Standardize dates
df["Date"] = (
    df["Date"].astype("string").str.strip().str.replace("'", "", regex=False)
)
df["Date"] = pd.to_datetime(df["Date"], format="mixed", errors="coerce")

# 2. Remove exact duplicate rows
df = df.drop_duplicates().copy()

# 3. Fill a missing date only when the daily sequence makes it unambiguous
missing_date = df["Date"].isna()
if missing_date.sum() == 1:
    idx = df.index[missing_date][0]
    prev_dates = df.loc[df.index < idx, "Date"].dropna()
    next_dates = df.loc[df.index > idx, "Date"].dropna()
    if len(prev_dates) and len(next_dates):
        prev_date, next_date = prev_dates.iloc[-1], next_dates.iloc[0]
        if (next_date - prev_date).days == 2:
            df.loc[idx, "Date"] = prev_date + pd.Timedelta(days=1)

# 4. Flag questionable values for review (do not silently delete them)
df["Duration_Suspicious"] = df["Duration"] > 180
df["Pulse_Maxpulse_Check"] = df["Maxpulse"] < df["Pulse"]

# 5. Handle missing calories with the median; keep an audit flag
df["Calories_Was_Missing"] = df["Calories"].isna()
df["Calories"] = df["Calories"].fillna(df["Calories"].median())

# 6. Create a new column
df["Calories_Per_Minute"] = (df["Calories"] / df["Duration"]).round(2)

# 7. Save the cleaned data
df.to_csv("cleaned_data.csv", index=False, date_format="%Y-%m-%d")

# 8. Visualizations
plt.figure(figsize=(8, 5))
plt.scatter(df["Duration"], df["Calories"])
plt.xlabel("Duration")
plt.ylabel("Calories")
plt.title("Workout Duration vs Calories")
plt.tight_layout()
plt.savefig("duration_vs_calories.png", dpi=150)
plt.show()

plt.figure(figsize=(7, 5))
numeric = df[["Duration", "Pulse", "Maxpulse", "Calories"]]
sns.heatmap(numeric.corr(), annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Fitness Dataset Correlation")
plt.tight_layout()
plt.savefig("fitness_correlation_heatmap.png", dpi=150)
plt.show()

print("Saved cleaned_data.csv and both charts.")
print(df.head())
