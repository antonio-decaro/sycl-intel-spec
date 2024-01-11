import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys

if len(sys.argv) != 3:
  print("Usage: python plot_control_flow.py <csv_file> <out_file>")
  sys.exit(1)
  
file_path = sys.argv[1]
out_file = sys.argv[2]

# Load the dataset
data = pd.read_csv(file_path)

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
    normalized_df[normalized_col] = merged_data[col_16] / merged_data[col_32]

# Adding 'kernel-name' and 'type' for plotting
normalized_df['kernel-name'] = merged_data['kernel-name']
normalized_df['type'] = merged_data['type']

# Melting the DataFrame for easier plotting
melted_normalized_df = pd.melt(normalized_df, id_vars=['kernel-name', 'type'], var_name='Instruction Type', value_name='Normalized Value')

# change the name of the columns by removing "Normalized GPU Instructions Executed"
melted_normalized_df['Instruction Type'] = melted_normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed:', ''))
melted_normalized_df['Instruction Type'] = melted_normalized_df['Instruction Type'].apply(lambda x: x.replace('Normalized GPU Instructions Executed', 'Total GPU Instructions'))

# Plotting
plt.figure(figsize=(15, 10))
sns.barplot(x='kernel-name', y='Normalized Value', hue='Instruction Type', data=melted_normalized_df)
plt.title('Normalized GPU Instructions (16 SIMD Baseline vs 32 SIMD)')
plt.ylabel('Normalized Instructions')
plt.ylim(top=3)
plt.axhline(y=1, color='black', linewidth=1)  # Baseline at speedup = 1
plt.xlabel('Kernel Name')
plt.xticks(rotation=45)
plt.legend(title='Instruction Type')
plt.tight_layout()
plt.grid(linestyle='--', alpha=0.5)
plt.savefig(out_file, dpi=1000)
