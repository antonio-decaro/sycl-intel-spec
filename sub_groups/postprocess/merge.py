from math import e
import pandas as pd
import sys
import glob
import os

types = {
  'long long': 'int64',
  'int': 'int32',
  'float': 'fp32',
  'double': 'fp64'
}

if __name__ == "__main__":
  if len(sys.argv) != 4:
    print(f"Usage: {sys.argv[0]} <parsed> <vtune-reports> <out-directory>", file=sys.stderr)
    exit(0)

  parsed = sys.argv[1]
  vtune_reports = sys.argv[2]
  out_dir = sys.argv[3]
  
  for fname in glob.glob(f"{parsed}/*.csv"):
    basename = fname.split("/")[-1].replace('_parsed.csv', '')
    df_parsed = pd.read_csv(fname)
    # add new column based on existing column
    type = False
    for key, value in types.items():
      if df_parsed['kernel-name'].str.contains(value).any():
        type = True
        break
      
    if type:
      df_parsed['type'] = df_parsed['kernel-name'].str.split('_').str[-1]
    
    df_vtune_1 = pd.read_csv(f"{vtune_reports}/overview/{basename}.csv", sep='\t')
    df_vtune_2 = pd.read_csv(f"{vtune_reports}/instructions/{basename}.csv", sep='\t')
    df_vtune_2.drop(columns=['Work Size:Global','Work Size:Local','Computing Task:Total Time','Computing Task:Average Time','Computing Task:Instance Count','Computing Task:SIMD Width','Computing Task:SVM Usage Type','Data Transferred:Size'], inplace=True)
    df_vtune = pd.merge(df_vtune_1, df_vtune_2, on=['Computing Task'], how='left', suffixes=('', ''))
    
    # delete row that does not contain a kernel name
    df_vtune = df_vtune.dropna(subset=['Work Size:Local'])
    # drop rows with a specific kernel name
    df_vtune = df_vtune[~df_vtune['Computing Task'].str.contains('InitializationDummyKernel')]
    if type:
      df_vtune['type'] = df_vtune['Computing Task'].str.split('<').str[1].str.split(',').str[0]
      # change with types dict
      df_vtune['type'] = df_vtune['type'].replace(types)
      df_merged = pd.merge(df_parsed, df_vtune, left_on=['simd', 'type'], right_on=['Computing Task:SIMD Width', 'type'], how='left')
    else:
      df_merged = pd.merge(df_parsed, df_vtune, left_on=['simd'], right_on=['Computing Task:SIMD Width'], how='left')
    
    # drop columns
    if type:
      df_merged = df_merged.drop(columns=['type'])
    df_merged = df_merged.drop(columns=['Computing Task', 'Computing Task:SIMD Width', 'Work Size:Global', 'Work Size:Local', 'Computing Task:Total Time', 'Computing Task:Average Time', 'Computing Task:Instance Count'])
    
    df_merged.to_csv(f"{out_dir}/{basename}_merged.csv", index=False)