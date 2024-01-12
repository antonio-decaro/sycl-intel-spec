import matplotlib.pyplot as plt
import numpy as np
import sys
import pandas as pd

if len(sys.argv) != 4:
    print("Usage: python speedup_plot.py <csv_file> <output_file> <simd_group>")
    sys.exit(1)

data = pd.read_csv(sys.argv[1])
output_file = sys.argv[2]
sg = int(sys.argv[3])

# Filter data for SIMD 32 and merge kernel names with data types
simd_32_data = data[data['simd'] == sg]
simd_32_data['type'].fillna('def', inplace=True)
simd_32_data['kernel_with_type'] = simd_32_data['kernel-name'] + " (" + simd_32_data['type'] + ")"

# Grouping by kernel name and data type, and sorting by speedup
grouped_data = simd_32_data.groupby('kernel_with_type')['speedup'].mean().reset_index()
grouped_sorted_data = grouped_data.sort_values(by='speedup', ascending=False)

# Create a list of unique kernel names from the sorted data
unique_kernels_sorted = grouped_sorted_data['kernel_with_type'].apply(lambda x: x.split(' (')[0]).unique()


# Generating more distinguishable shades of green and red for each kernel
def generate_distinguishable_shades(base_color, unique_kernels):
    base = plt.cm.get_cmap(base_color)
    return {kernel: base(i / len(unique_kernels)) for i, kernel in enumerate(unique_kernels)}

# Creating more distinguishable shades for each kernel
distinguishable_green_shades = generate_distinguishable_shades('Greens', unique_kernels_sorted)
distinguishable_red_shades = generate_distinguishable_shades('Reds', unique_kernels_sorted)

# Plotting with more distinguishable shades
plt.figure(figsize=(14, 10))
for _, row in grouped_sorted_data.iterrows():
    kernel_name = row['kernel_with_type'].split(' (')[0]
    green_color = distinguishable_green_shades[kernel_name]
    red_color = distinguishable_red_shades[kernel_name]
    speedup = row['speedup']
    color = green_color if speedup >= 1 else red_color
    plt.bar(row['kernel_with_type'], speedup, color=color, edgecolor='black')

plt.axhline(y=1, color='black', linewidth=1)  # Baseline at speedup = 1
plt.xticks(rotation=45, ha='right')
plt.xlabel('Kernel Name with Data Type')
plt.ylabel('Speedup')
plt.title(f'SIMD {sg} Speedups')
plt.ylim(bottom=0.5)  # Set the bottom limit of the Y-axis to 0.5
plt.tight_layout()
plt.grid(linestyle='--', alpha=0.5)
plt.savefig(output_file, dpi=1000)