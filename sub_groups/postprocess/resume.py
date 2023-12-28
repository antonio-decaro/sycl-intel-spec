import pandas as pd
import sys
import os
from scipy import stats

if len(sys.argv) != 3:
  print("Usage: python script.py <kernel_dir> <out_file>")
  sys.exit(1)
  
def get_data(data: pd.DataFrame, resume_df: pd.DataFrame, kernel_name, default_simd=16):
  grouped = data.groupby(["simd"])
  times = grouped['run-time[s]'].apply(stats.gmean)
  
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

    resume_df.loc[len(resume_df)] = [name, type, simd, speedup, xve_occupancy, xve_utilization_active, xve_utilization_idle, xve_utilization_stalled]

kernels_dir = sys.argv[1]
outfile = sys.argv[2]

resume_df = pd.DataFrame(columns=["kernel-name", "type", "simd", "speedup", "XVE Threads Occupancy(%)", "XVE Array:Active(%)", "XVE Array:Idle(%)", "XVE Array:Stalled(%)"])

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