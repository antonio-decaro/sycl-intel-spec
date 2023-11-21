#!/bin/env python3

import sys
import os
import time
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", None)
plt.rcParams['axes.grid'] = True  # Show grid on plots

ticks_size=4
axis_label_size=13
font_size=11
scatter_size=15
legend_size=11
bar_width=0.25
subgroup_sizes=[8, 16, 32]
logscale = False
time_unit="s"

pd.set_option("display.width", 1000)

def generate_and_save_plot(data, kernel_name, output_dir):
    data = pd.DataFrame(data)

    plt.clf()
    plt.figure(figsize=(4, 6))
    bar_positions = np.arange(len(data['simd'])) * bar_width

    if time_unit == "ms":
        y = data['run-time-mean[ms]']
        yerr = data['run-time-stddev[ms]']
    elif time_unit == "us":
        y = data['run-time-mean[us]']
        yerr = data['run-time-stddev[us]']
    else:
        y = data['run-time-mean[s]']
        yerr = data['run-time-stddev[s]']
    
    plt.errorbar(bar_positions, y, yerr, fmt='o', linewidth=2, capsize=6)
    plt.xticks(bar_positions, data['simd'], fontsize=font_size)
    plt.xlabel('SIMD')
    plt.ylabel(f'Run Time ({time_unit})')
    if logscale:
        plt.yscale('log')
    plt.title(kernel_name)

    plt.xlim(bar_positions[0] - bar_width, bar_positions[-1] + bar_width)

    output_file = os.path.join(output_dir, f'{kernel_name}.pdf')
    plt.savefig(output_file, bbox_inches="tight")
    print(f"Plot saved: {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <kernel_dir> <output_dir> <logscale> <time_unit>")
        sys.exit(1)

    kernels_dir = sys.argv[1]
    output_dir = sys.argv[2]
    logscale = sys.argv[3] == "True"
    time_unit = sys.argv[4]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for file in os.listdir(kernels_dir):
        try:
            df = pd.read_csv(os.path.join(kernels_dir, file))

            # Convert run-time to ms, us, and ns
            df['run-time-mean[ms]'] = df['run-time-mean[s]'] * 1000
            df['run-time-stddev[ms]'] = df['run-time-stddev[s]'] * 1000
            df['run-time-mean[us]'] = df['run-time-mean[s]'] * 1000000
            df['run-time-stddev[us]'] = df['run-time-stddev[s]'] * 1000000
            df['run-time-mean[ns]'] = df['run-time-mean[s]'] * 1000000000
            df['run-time-stddev[ns]'] = df['run-time-stddev[s]'] * 1000000000
            kernel_names = df["kernel-name"].unique()

            for kernel_name in kernel_names:
                data = df[df["kernel-name"] == kernel_name]
                generate_and_save_plot(data, kernel_name, output_dir)
        except Exception as e:
            print(f"Error while processing {file}: {e}")
            continue