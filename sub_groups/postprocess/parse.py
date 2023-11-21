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
            output_file.write("kernel-name,simd,size,kernel-time-mean[s],kernel-time-stddev[s],kernel-time-min[s],kernel-time-max[s],run-time-mean[s],run-time-stddev[s],run-time-min[s],run-time-max[s]\n")
            for line in input_file:
                line:str
                if "Results for" in line:
                    line = line.replace("*", "")
                    line = line.replace("Results for", "")
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    subgr = line[line.find("_sg"):].replace("_sg", "")
                    line = line[0:line.find("_sg")]
                    output_file.write(line + "," + subgr)
                if "problem-size:" in line:
                    line = line.replace("problem-size:", "")
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)  
                if "kernel-time-mean:" in line:
                    line = line.replace("kernel-time-mean:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "kernel-time-stddev:" in line:
                    line = line.replace("kernel-time-stddev:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "kernel-time-min:" in line:
                    line = line.replace("kernel-time-min:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "kernel-time-max:" in line:
                    line = line.replace("kernel-time-max:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                    kernel_time_max=True
                if "run-time-mean:" in line:
                    line = line.replace("run-time-mean:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "run-time-stddev:" in line:
                    line = line.replace("run-time-stddev:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "run-time-min:" in line:
                    line = line.replace("run-time-min:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line)
                if "run-time-max:" in line:
                    line = line.replace("run-time-max:", "")
                    line = line.replace("[s]", "")  
                    line = line.replace(" ", "")
                    line = line.replace("\n", "")
                    output_file.write(","+ line + "\n")
        if not kernel_time_max:
            with open(f"{out_dir}/{out_file}_parsed.csv", "r") as f:
                lines = f.readlines()
                lines[0] = lines[0].replace(',kernel-time-max[s]', '')

            with open(f"{out_dir}/{out_file}_parsed.csv", "w") as f:
                f.writelines(lines)
    except Exception as e:
        print(e)
        continue
