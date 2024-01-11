import pandas as pd
import sys
import os
from scipy import stats

if len(sys.argv) != 3:
  print("Usage: python script.py <kernel_dir> <out_file>")
  sys.exit(1)
  
def get_data(data: pd.DataFrame, resume_df: pd.DataFrame, kernel_name, default_simd=16):
  grouped = data.groupby(["simd"])
  col_name = 'kernel-time[s]'
  if data[col_name].isnull().values.any():
    col_name = 'run-time[s]'
  times = grouped[col_name].apply(stats.gmean)
  
  for name, grp in grouped:
    simd = grp['simd'].unique()[0]
    speedup = times[default_simd] / times[simd]
    if "int" in kernel_name or "fp" in kernel_name:
      type = kernel_name.split("_")[-1]
      name = kernel_name.replace("_" + type, "")
    else:
      type = ''
      name = kernel_name
    xve_occupancy = grp['XVE Threads Occupancy(%)'].mean()
    xve_utilization_active = grp['XVE Array:Active(%)'].mean()
    xve_utilization_idle = grp['XVE Array:Idle(%)'].mean()
    xve_utilization_stalled = grp['XVE Array:Stalled(%)'].mean()
    
    v0 = grp['Computing Threads Started'].mean()
    v1 = grp["XVE Instructions:ALU0 active(%)"].mean()
    v2 = grp["XVE Instructions:ALU1 active(%)"].mean()
    v3 = grp["XVE Instructions:ALU2 active(%)"].mean()
    v4 = grp['XVE Instructions:Send active(%)'].mean()
    v5 = grp['XVE Instructions:Branch active(%)'].mean()
    v6 = grp['L3 Read Bandwidth, GB/sec'].mean()
    v7 = grp['L3 Write Bandwidth, GB/sec'].mean()
    v8 = grp['GPU Memory Bandwidth, GB/sec:Read'].mean()
    v9 = grp['GPU Memory Bandwidth, GB/sec:Write'].mean()
    v10 = grp["GPU Instructions Executed"].mean()
    v11 = grp["GPU Instructions Executed:Control Flow"].mean()
    v12 = grp["GPU Instructions Executed:Send"].mean()
    v13 = grp["GPU Instructions Executed:Int32 & SP Float"].mean()
    v14 = grp["GPU Instructions Executed:Int64 & DP Float"].mean()
    v15 = grp["GPU Instructions Executed:Other"].mean()
    v16 = grp["SIMD Utilization(%)"].mean()

    resume_df.loc[len(resume_df)] = [name, type, simd, speedup, xve_occupancy, xve_utilization_active, xve_utilization_idle, xve_utilization_stalled, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16]

kernels_dir = sys.argv[1]
outfile = sys.argv[2]

columns = ["kernel-name", 
           "type", 
           "simd", 
           "speedup", 
           "XVE Threads Occupancy(%)", 
           "XVE Array:Active(%)", 
           "XVE Array:Idle(%)", 
           "XVE Array:Stalled(%)",
           'Computing Threads Started',
           "XVE Instructions:ALU0 active(%)",
           "XVE Instructions:ALU1 active(%)",
           "XVE Instructions:ALU2 active(%)",
           "XVE Instructions:Send active(%)",
           "XVE Instructions:Branch active(%)",
           "L3 Read Bandwidth, GB/sec",
           "L3 Write Bandwidth, GB/sec",
           "GPU Memory Bandwidth, GB/sec:Read",
           "GPU Memory Bandwidth, GB/sec:Write",
           "GPU Instructions Executed",
           "GPU Instructions Executed:Control Flow",
           "GPU Instructions Executed:Send",
           "GPU Instructions Executed:Int32 & SP Float",
           "GPU Instructions Executed:Int64 & DP Float",
           "GPU Instructions Executed:Other",
           "SIMD Utilization(%)",
           ]
resume_df = pd.DataFrame(columns=columns)

for file in os.listdir(kernels_dir):
  df = pd.read_csv(os.path.join(kernels_dir, file))

  # Convert run-time to ms, us, and ns
  kernel_names = df["kernel-name"].unique()

  for kernel_name in kernel_names:
    data = df[df["kernel-name"] == kernel_name]
    get_data(data, resume_df, kernel_name)

ext = outfile.split('.')[-1]
if ext == "csv":
  resume_df.to_csv(outfile, index=False)
elif ext == "txt":
  resume_df.to_string(outfile, index=False)
else:
  print("Invalid output format", file=sys.stderr)
  sys.exit(1)