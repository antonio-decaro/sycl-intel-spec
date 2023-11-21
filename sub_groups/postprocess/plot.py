#!/bin/env python3

from math import sqrt
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
single_plot=False

pd.set_option("display.width", 1000)

def generate_plot(data, kernel_name):
    data = pd.DataFrame(data)

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

    plt.ylim(0, max(y) + max(yerr) * 1.1)
    plt.ylim(max(0, (y.min() - yerr.max()) * 0.9), (y.max() + yerr.max()) * 1.1)

    plt.xlim(bar_positions[0] - bar_width, bar_positions[-1] + bar_width)

def get_plots_number(dir):
    n = 0
    for file in os.listdir(kernels_dir):
        df = pd.read_csv(os.path.join(kernels_dir, file))
        kernel_names = df["kernel-name"].unique()
        for kernel_name in kernel_names:
                n += 1
    return n

def generate_time_units(df):
    df['run-time-mean[ms]'] = df['run-time-mean[s]'] * 1000
    df['run-time-stddev[ms]'] = df['run-time-stddev[s]'] * 1000
    df['run-time-min[ms]'] = df['run-time-min[s]'] * 1000
    df['run-time-max[ms]'] = df['run-time-max[s]'] * 1000
    df['run-time-mean[us]'] = df['run-time-mean[s]'] * 1000000
    df['run-time-stddev[us]'] = df['run-time-stddev[s]'] * 1000000
    df['run-time-min[us]'] = df['run-time-min[s]'] * 1000000
    df['run-time-max[us]'] = df['run-time-max[s]'] * 1000000
    df['run-time-mean[ns]'] = df['run-time-mean[s]'] * 1000000000
    df['run-time-stddev[ns]'] = df['run-time-stddev[s]'] * 1000000000
    df['run-time-min[ns]'] = df['run-time-min[s]'] * 1000000000
    df['run-time-max[ns]'] = df['run-time-max[s]'] * 1000000000
    return df

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python script.py <kernel_dir> <output_dir> <logscale> <time_unit> <single_plot>")
        sys.exit(1)

    kernels_dir = sys.argv[1]
    output_dir = sys.argv[2]
    logscale = sys.argv[3] == "True"
    time_unit = sys.argv[4]
    single_plot = sys.argv[5] == "True"

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    size = 1
    i = 1
    if single_plot:
        plt.clf()
        n_plots = get_plots_number(kernels_dir)
        size = int(sqrt(n_plots))
        size = size + 1 if size * size < n_plots else size
        plt.figure(figsize=(size * 4, size * 6))
        plt.subplot(size, size, 1)

    for file in os.listdir(kernels_dir):
        if not single_plot:
            plt.clf()
            plt.figure(figsize=(4, 6))
        try:
            df = pd.read_csv(os.path.join(kernels_dir, file))

            # Convert run-time to ms, us, and ns
            df = generate_time_units(df)
            kernel_names = df["kernel-name"].unique()

            for kernel_name in kernel_names:
                data = df[df["kernel-name"] == kernel_name]
                if single_plot:
                    plt.subplot(size, size, i)
                    i += 1
                generate_plot(data, kernel_name)
                if not single_plot:
                    output_file = os.path.join(output_dir, f'{kernel_name}.pdf')
                    plt.savefig(output_file, bbox_inches="tight")
                    print(f"Plot saved: {output_file}")

        except Exception as e:
            print(f"Error while processing {file}: {e}")
            continue
    if single_plot:
        output_file = os.path.join(output_dir, f'plot.pdf')
        plt.tight_layout()
        plt.savefig(output_file, bbox_inches="tight")
        print(f"Plot saved: {output_file}")