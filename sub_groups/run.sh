#!/bin/bash

runs=5
local=256
AVAILABLE_TARGETS="vec_add:134217728 matrix_mul:4096 spmv:8192 spgemm:512 nbody:8192 scalar_prod:8388608 sobel:8192 median:8192 lin_reg_coeff:67108864 kmeans:67108864 mol_dyn:33554432 merse_twister:67108864 black_scholes:67108864"
selected_targets=""
running_targets=""
avoid_overwrite=false
target_specified=false

# function to print help
help()
{
  echo "Usage: ./run.sh
    [ -t= ] Specify the targets to run with their sizes. If not specified, all targets will be run with their default sizes;
    [ --runs= ] Specify the number of runs for each target. Default is 5;
    [ --local= ] Specify the local size for each target. Default is 256;
    [ --avoid-overwrite ] Avoid overwriting the results of previous runs;
    [ -h | --help ] Print this help message and exit."
  echo -n "Available targets: "
  for pair in $AVAILABLE_TARGETS; do
    name=""
    value=""
    IFS=":" read -r name value <<< "$pair"
    echo -n "$name "
  done
  echo ""
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t=*)
      selected_targets+="${1#*=} "
      shift
      ;;
    --avoid-overwrite)
      avoid_overwrite=true
      shift
      ;;
    --runs=*)
      runs="${1#*=}"
      shift
      ;;
    --local=*)
      local="${1#*=}"
      shift
      ;;
    -h | --help)
      help
      exit 0
      ;;
    *)
      echo "Invalid argument: $1"
      return 1 2>/dev/null
      exit 1
      ;;
  esac
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BENCH_DIR=$SCRIPT_DIR/../build

# check if the specified targets are valid
for pair in $selected_targets; do
  target_specified=true
  name=""
  if [[ $pair == *:* ]]; then
    # Split the pair into name and value if ':' is present
    IFS=":" read -r name value <<< "$pair"
    # check if the name is valid
    if [[ $AVAILABLE_TARGETS != *"$name"* ]]; then
      echo "Invalid target name: $name"
      exit 1
    fi
    if [[ $value =~ ^[0-9]+$ ]]; then
      # check if the value is valid
      if [[ $value -lt 1 ]]; then
        echo "Invalid target value: $value"
        exit 1
      fi
    else
      echo "Invalid target value: $value"
      exit 1
    fi
    running_targets+="$name:$value "
  else
    # Just the name is present
    name=$pair
    # check if the name is valid
    if [[ $AVAILABLE_TARGETS != *"$name"* ]]; then
      echo "Invalid target name: $name"
      exit 1
    fi
    # set the default value presents in AVAILABLE_TARGETS
    value=$(echo $AVAILABLE_TARGETS | grep -o "$name:[^ ]*" | grep -o "[^:]*$")
    running_targets+="$name:$value "
  fi
done

if [ "$target_specified" = false ]; then
  running_targets=$AVAILABLE_TARGETS
fi

echo "[*] Running benchmarks: $running_targets"

mkdir -p $SCRIPT_DIR/tmp
mkdir -p $SCRIPT_DIR/tmp/logs
mkdir -p $SCRIPT_DIR/tmp/vtune-reports
mkdir -p $SCRIPT_DIR/tmp/vtune-reports/overview
mkdir -p $SCRIPT_DIR/tmp/vtune-reports/instructions

for pair in $running_targets; do
  name=""
  value=""
  IFS=":" read -r name value <<< "$pair"
  if [ "$avoid_overwrite" = true ]; then
    if [ -f "$SCRIPT_DIR/tmp/logs/$name.log" ]; then
      echo "[-] Skipping $name"
      continue
    fi
  fi
  echo "[-] Running $name with size $value"
  vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r000{at} -- $BENCH_DIR/$name \
    --size=$value --local=$local --seed=0 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/$name.log
  vtune -collect gpu-hotspots -k characterization-mode=instruction-count -r $SCRIPT_DIR/tmp/r001{at} -- $BENCH_DIR/$name \
    --size=$value --local=$local --seed=0 --num-iters=1 --device=gpu --num-runs=$runs > /dev/null
  vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/overview/$name.csv
  vtune -report hotspots -r $SCRIPT_DIR/tmp/r001gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/instructions/$name.csv
  rm -rf $SCRIPT_DIR/tmp/r000gh
  rm -rf $SCRIPT_DIR/tmp/r001gh
done

echo "[*] Done"