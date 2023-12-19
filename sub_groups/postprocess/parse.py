#!/usr/bin/python3

import os
import sys

if len(sys.argv) != 3:
    print("Insert path to sycl-bench folder as command line argument")
    exit(0)

work_dir=sys.argv[1]
out_dir=sys.argv[2]

if not os.path.exists(out_dir):
    os.makedirs(out_dir)

for file in os.listdir(work_dir):
    out_file = file.replace(".log","")
    try:
        kernel_time_max=False
        with open(f"{work_dir}/{file}", "r") as input_file, open(f"{out_dir}/{out_file}_parsed.csv", "w") as output_file:
            output_file.write("kernel-name,simd,size,kernel-time[s],run-time[s]\n")
            vals_kernel = []
            vals_runtime = []
            name = ""
            simd = ""
            size = ""
            for line in input_file:
                line:str
                if "Results for" in line:
                    line = line.replace("*", "")
                    line = line.replace("Results for", "")
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    subgr = line[line.find("_sg"):].replace("_sg", "")
                    line = line[0:line.find("_sg")]
                    name = line
                    simd = subgr
                if "problem-size:" in line:
                    line = line.replace("problem-size:", "")
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    size = line
                if "kernel-time-samples:" in line:
                    samples = line.replace("kernel-time-samples: ", "")
                    samples = samples.replace("\"", "")
                    samples = samples.strip()
                    for sample in samples.split(" "):
                        vals_kernel.append(sample)
                if "run-time-samples:" in line:
                    samples = line.replace("run-time-samples: ", "")
                    samples = samples.replace("\"", "")
                    samples = samples.strip()
                    for sample in samples.split(" "):
                        vals_runtime.append(sample)
                if len(vals_kernel) != len(vals_runtime):
                    vals_kernel = ['N/A' for _ in range(len(vals_runtime))]
                for kernel, runtime in zip(vals_kernel, vals_runtime):
                    output_file.write(f"{name},{simd},{size},{kernel},{runtime}\n")
                    vals_kernel = []
                    vals_runtime = []
    except Exception as e:
        print(e)
        continue
