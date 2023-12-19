#!/bin/env python3

from math import sqrt
import sys
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", None)
plt.rcParams['axes.grid'] = True  # Show grid on plots

ticks_size=4
axis_label_size=13
font_size=11
scatter_size=15
legend_size=11
bar_width=10
subgroup_sizes=[8, 16, 32]
logscale = False
time_unit="s"
single_plot=False

pd.set_option("display.width", 1000)

def generate_plot(data, kernel_name):
    data = pd.DataFrame(data)
    
    col_name = f'kernel-time[{time_unit}]'
    if data[col_name].isnull().values.any():
        col_name = f'run-time[{time_unit}]'
        
    vals = []
    for simd in data[col_name].groupby(data['simd']):
        vals.append(simd[1].values)

    labels = [s for s in data['simd'].unique()]
    
    plt.boxplot(vals, patch_artist=True, labels=labels, showfliers=False)

    plt.xlabel('SIMD')
    plt.ylabel(f'Run Time ({time_unit})')
    if logscale:
        plt.yscale('log')
    plt.title(kernel_name)

def get_plots_number(dir):
    n = 0
    for file in os.listdir(kernels_dir):
        df = pd.read_csv(os.path.join(kernels_dir, file))
        kernel_names = df["kernel-name"].unique()
        for kernel_name in kernel_names:
                n += 1
    return n

def generate_time_units(df):
    df['run-time[ms]'] = df['run-time[s]'] * 1000
    df['run-time[us]'] = df['run-time[s]'] * 1000000
    df['run-time[ns]'] = df['run-time[s]'] * 1000000000
    df['kernel-time[ms]'] = df['kernel-time[s]'] * 1000
    df['kernel-time[us]'] = df['kernel-time[s]'] * 1000000
    df['kernel-time[ns]'] = df['kernel-time[s]'] * 1000000000
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
        try:
            df = pd.read_csv(os.path.join(kernels_dir, file))

            # Convert run-time to ms, us, and ns
            df = generate_time_units(df)
            kernel_names = df["kernel-name"].unique()

            for kernel_name in kernel_names:
                if not single_plot:
                    plt.clf()
                    plt.figure(figsize=(4, 6))
                # if (kernel_name != "VectorAddition_fp32"):
                #     continue
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