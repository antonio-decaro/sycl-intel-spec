import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import numpy as np
import math

top_lim = 2

if len(sys.argv) != 3:
  print("Usage: python plot_control_flow.py <csv_file> <out_file>")
  sys.exit(1)
  
file_path = sys.argv[1]
out_file = sys.argv[2]

# Load the dataset
data = pd.read_csv(file_path)
data['type'].fillna('unk', inplace=True)

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

# calculating the number of kernels
n_kernels = merged_data['kernel-name'].nunique()

# Adding 'kernel-name' and 'type' for plotting
normalized_df['kernel-name'] = merged_data['kernel-name']
normalized_df['type'] = merged_data['type']

# Melting the DataFrame for easier plotting
normalized_df = pd.melt(normalized_df, id_vars=['kernel-name', 'type'], var_name='Instruction Type', value_name='Normalized Value')

# change the name of the columns by removing "Normalized GPU Instructions Executed"
normalized_df['Instruction Type'] = normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed:', ''))
normalized_df['Instruction Type'] = normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed', 'Total GPU Instructions'))

cols = math.ceil(math.sqrt(n_kernels))
rows = math.ceil(n_kernels / cols)
fig, axs = plt.subplots(rows, cols, figsize=(15, 10))

for i, ax in enumerate(axs.flat):
  ax: plt.Axes
  if i >= n_kernels:
    ax.set_visible(False)
    continue
  kernel_name = normalized_df['kernel-name'].unique()[i]
  df = normalized_df[normalized_df['kernel-name'] == kernel_name]
  axx = sns.barplot(x='Normalized Value', y='Instruction Type', hue='type', data=df, ax=ax, palette='dark')
  for p in axx.patches:
    width = p.get_width()
    if width > top_lim:
      height = p.get_height()
      fontsize = 4 / (1 - height)
      axx.text(top_lim + 0.02, p.get_y() + height, '{:1.2f}'.format(width), fontsize=fontsize, ha="left", color='black')
  if i % cols != 0:
    ax.set_ylabel('')
    ax.set_yticklabels([])
  if i / cols < rows - 1:
    ax.set_xlabel('')

  ax.set_xlim(0, top_lim)
  ax.set_xticks([0, 0.5, 1, 1.5, 2])
  ax.set_title(kernel_name)
  if (df['type'].unique().size == 1):
    ax.legend().set_visible(False)
  ax.axvline(x=1, linestyle=":", color='black')

fig.tight_layout(pad=3)
fig.suptitle('Normalized GPU Instructions Executed (32 SIMD / 16 SIMD)')
plt.savefig(out_file)
