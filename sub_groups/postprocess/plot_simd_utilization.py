import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import sys

if len(sys.argv) != 3:
  print("Usage: python plot_simd_utilization.py <csv_file> <out_file>")
  sys.exit(1)
  
file_path = sys.argv[1]
out_file = sys.argv[2]

sns.set_theme(style="whitegrid")

# Initialize the matplotlib figure
f, ax = plt.subplots(figsize=(6, 15))

# Read the dataset, and set default value for 'type' column
data = pd.read_csv(file_path)
data['type'].fillna('def', inplace=True)

# Filtering data for 32 SIMD and 16 SIMD
data_32_simd = data[data['simd'] == 32]
data_16_simd = data[data['simd'] == 16]

# Matching the rows based on 'kernel-name' and 'type'
# This assumes that each combination of 'kernel-name' and 'type' is unique
merged_data = pd.merge(data_16_simd, data_32_simd, on=['kernel-name', 'type'], suffixes=('_16', '_32'))

# Merge the kernel names with tha data type
merged_data['merged-kernel-name'] = merged_data['kernel-name'] + ' (' + merged_data['type'] + ')'

# Plot the total crashes
sns.set_color_codes("pastel")
sns.barplot(x="SIMD Utilization(%)_16", y='merged-kernel-name', data=merged_data,
            label="SIMD 16 (Baseline)", color="b")

# Plot the crashes where alcohol was involved
sns.set_color_codes("muted")
sns.barplot(x="SIMD Utilization(%)_32", y='merged-kernel-name', data=merged_data,
            label="SIMD 32", color="r", alpha=0.5)

# Add a legend and informative axis label
ax.legend(ncol=2, loc="upper center", frameon=True, bbox_to_anchor=(0.5, 1.05))
ax.set(xlim=(60, 100), ylabel="",
       xlabel="SIMD Utilization(%)")
sns.despine(left=True, bottom=True)

plt.tight_layout()
plt.savefig(out_file, dpi=1000)
