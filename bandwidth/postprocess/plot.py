#!/bin/env python3

import matplotlib.pyplot as plt
import numpy as np
import sys
import pandas as pd
import glob
from io import StringIO

in_dir = ""
out_dir = ""

def plot(df: pd.DataFrame):
  # Clean up
  clean_fn = lambda x: x.replace(' Bandwidth', '').replace(' Peak', '').replace(' Vector', '').replace(' ', '-')
  df['Name'] = df['Name'].replace(df['Name'].values, list(map(clean_fn, df['Name'].values)))

  # Normalize values
  df['Bandwidth'] = df['Bandwidth'] / 1e9

  # Plot memory boundaries
  df = df.groupby('Name').max().reset_index()
  df_memory = df[df['Type'] == 'memory']
  df_compute = df[df['Type'] == 'compute']

  plt.subplot(1, 2, 1)
  plt.title("Memory Boundaries")
  plt.xlabel("Memory Type")
  plt.ylabel("GB/s")

  bars_memory = plt.bar(df_memory["Name"], df_memory["Bandwidth"], color='b')

  # Annotate memory bars with values
  for bar in bars_memory:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, yval, round(yval, 2), ha='center', va='bottom')

  plt.subplot(1, 2, 2)
  plt.title("Compute Boundaries")
  plt.xlabel("Operation")
  plt.ylabel("GFLOPS")

  # Plot compute boundaries
  bars_compute = plt.bar(df_compute["Name"], df_compute["Bandwidth"], color='r')
  for bar in bars_compute:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, yval, round(yval, 2), ha='center', va='bottom')

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("Usage: python3 plot.py <in_dir> <out_file>")
    exit(1)

  in_dir = sys.argv[1]
  out_file = sys.argv[2]

  # Read all csv files in in_dir
  csv_files = []
  for fname in glob.glob(in_dir + "/*.csv"):
    with open(fname, 'r') as f:
      data = StringIO("".join(f.readlines()[1:]))
      csv_files.append(data)
  
  df = pd.concat((pd.read_csv(f) for f in csv_files))
  df = df.drop(df[df['TargetDevice'] == 'CPU'].index)

  # Plot
  plot(df)
  plt.tight_layout()
  plt.savefig(out_file)
