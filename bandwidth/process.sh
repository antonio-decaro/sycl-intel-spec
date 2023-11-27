#!/bin/bash

delete_directory=false

help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --delete-tmp-directory"
  echo "    Delete the temporary directory after generating reports"
  echo "  -h, --help"
  echo "    Print this help message"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete-tmp-directory)
      delete_directory=true
      shift
      ;;
    -h |--help)
      help
      return 0 2>/dev/null
      exit 0
      ;;
    *)
      echo "Invalid argument: $1"
      help
      return 1 2>/dev/null
      exit 1
  esac
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p $SCRIPT_DIR/logs
mkdir -p $SCRIPT_DIR/plots

echo "[*] Generating reports..."
advisor --report=roofline --gpu --project-dir=$SCRIPT_DIR/tmp/host_device_bandwidth --report-output=$SCRIPT_DIR/plots/host_device_bandwidth.html
advisor --report=roofline --gpu --project-dir=$SCRIPT_DIR/tmp/local_mem --report-output=$SCRIPT_DIR/plots/local_mem.html
advisor --report=roofs --gpu --format=csv --project-dir=$SCRIPT_DIR/tmp/host_device_bandwidth --report-output=$SCRIPT_DIR/logs/host_device_bandwidth.csv
advisor --report=roofs --gpu --format=csv --project-dir=$SCRIPT_DIR/tmp/local_mem --report-output=$SCRIPT_DIR/logs/local_mem.csv

if [ $delete_directory = true ]; 
then
  echo "[*] Deleting temporary directory..."
  rm -rf $SCRIPT_DIR/tmp
fi

echo "[*] Done"