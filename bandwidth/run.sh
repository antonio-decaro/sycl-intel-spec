#!/bin/bash

runs=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs=*)
      runs="${1#*=}"
      shift
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

# Running benchmarks
echo "[*] Running benchmarks..."

mkdir -p $SCRIPT_DIR/tmp

advisor --collect=roofline --profile-gpu --project-dir=$SCRIPT_DIR/tmp/host_device_bandwidth -- \
  $BENCH_DIR/host_device_bandwidth --size=256 --local=32 --device=gpu --num-runs=$runs
advisor --collect=roofline --profile-gpu --project-dir=$SCRIPT_DIR/tmp/local_mem -- \
  $BENCH_DIR/local_mem --size=8388608 --device=gpu --num-runs=$runs 

echo "[*] Done"
