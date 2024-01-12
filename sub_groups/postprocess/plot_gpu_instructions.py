import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import numpy as np

top_lim = 2.25

if len(sys.argv) != 3:
  print("Usage: python plot_control_flow.py <csv_file> <out_file>")
  sys.exit(1)
  
file_path = sys.argv[1]
out_file = sys.argv[2]

# Load the dataset
data = pd.read_csv(file_path)
data['type'].fillna('fp32', inplace=True)

# Filtering data for 32 SIMD and 16 SIMD
data_32_simd = data[data['simd'] == 32]
data_16_simd = data[data['simd'] == 16]

# Matching the rows based on 'kernel-name' and 'type'
# This assumes that each combination of 'kernel-name' and 'type' is unique
merged_data = pd.merge(data_16_simd, data_32_simd, on=['kernel-name', 'type'], suffixes=('_16', '_32'))

# Extracting columns with 'GPU Instructions' in their name
instruction_columns = [col for col in data.columns if 'GPU Instructions' in col]

# Creating a new DataFrame for normalized values
normalized_df = pd.DataFrame()

# Normalizing each instruction type
for col in instruction_columns:
    col_16 = col + '_16'
    col_32 = col + '_32'
    normalized_col = 'Normalized ' + col

    # Normalizing (16 SIMD / 32 SIMD)
    normalized_df[normalized_col] = merged_data[col_32] / merged_data[col_16]

# Adding 'kernel-name' and 'type' for plotting
normalized_df['kernel-name'] = merged_data['kernel-name']
normalized_df['type'] = merged_data['type']

# Melting the DataFrame for easier plotting
normalized_df = pd.melt(normalized_df, id_vars=['kernel-name', 'type'], var_name='Instruction Type', value_name='Normalized Value')
print(normalized_df.columns)

# change the name of the columns by removing "Normalized GPU Instructions Executed"
normalized_df['Instruction Type'] = normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed:', ''))
normalized_df['Instruction Type'] = normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed', 'Total GPU Instructions'))

cols = len(instruction_columns)
rows = normalized_df['kernel-name'].nunique()

# sns.barplot(x='kernel-name', y='Normalized Value', hue='Instruction Type', data=normalized_df)
# Initialize a grid of plots with an Axes for each InstructionType
grid = sns.FacetGrid(normalized_df, col='kernel-name', margin_titles=True, height=3, palette='bright')

# Draw a horizontal line to show the starting point
grid.refline(x=1, linestyle=":")

def barplot(data, **kwargs):
  sns.barplot(x='Normalized Value', y='Instruction Type', hue='type',  data=data, **kwargs)

grid.map_dataframe(barplot)
grid.set(xlim=(0, 2))
grid.set_titles(col_template="{col_name}")

grid.fig.suptitle('Normalized GPU Instructions (16 SIMD Baseline vs 32 SIMD)')
grid.fig.tight_layout()




# plt.title('Normalized GPU Instructions (16 SIMD Baseline vs 32 SIMD)')
# plt.ylabel('Normalized Instructions')
# # plt.axhline(y=1, color='black', linewidth=1)  # Baseline at speedup = 1
# # plt.xlabel('Kernel Name')
# # plt.xticks(rotation=45)
# plt.tight_layout(w_pad=1, h_pad=1)
# plt.grid(linestyle='--', alpha=0.5)
plt.savefig(out_file, dpi=1000)
