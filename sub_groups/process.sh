#!/bin/bash

logscale=False
time_unit="s"
single_plot=False
no_venv=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --logscale*)
      logscale=True
      shift
      ;;
    --single-plot*)
      single_plot=True
      shift
      ;;
    --time-unit=*)
      time_unit="${1#*=}"
      shift
      ;;
    --no-venv*)
      no_venv=true
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

if [ "$no_venv" = true ]; then
  echo "[*] Skipping virtual environment creation"
  pip3 install -r $SCRIPT_DIR/postprocess/requirements.txt
else
  # check if venv folder exists
  if [ ! -d "$SCRIPT_DIR/postprocess/.venv" ]; then
    echo "[*] Creating virtual environment..."
    python3 -m venv $SCRIPT_DIR/postprocess/.venv
    pip3 install -r $SCRIPT_DIR/postprocess/requirements.txt
  else
    echo "[*] Virtual environment already exists"
  fi
  source $SCRIPT_DIR/postprocess/.venv/bin/activate
fi

echo "[*] Postprocessing logs..."

mkdir -p $SCRIPT_DIR/tmp/parsed
mkdir -p $SCRIPT_DIR/tmp/merged
mkdir -p $SCRIPT_DIR/plots
mkdir -p $SCRIPT_DIR/plots/time
mkdir -p $SCRIPT_DIR/plots/xve-utilization
mkdir -p $SCRIPT_DIR/plots/xve-occupancy
mkdir -p $SCRIPT_DIR/plots/speedup

python3 $SCRIPT_DIR/postprocess/parse.py $SCRIPT_DIR/tmp/logs $SCRIPT_DIR/tmp/parsed
python3 $SCRIPT_DIR/postprocess/merge.py $SCRIPT_DIR/tmp/parsed $SCRIPT_DIR/tmp/vtune-reports $SCRIPT_DIR/tmp/merged
python3 $SCRIPT_DIR/postprocess/plot_time.py $SCRIPT_DIR/tmp/merged $SCRIPT_DIR/plots/time $logscale $time_unit $single_plot
python3 $SCRIPT_DIR/postprocess/plot_xve_utilization.py $SCRIPT_DIR/tmp/merged $SCRIPT_DIR/plots/xve-utilization $single_plot
python3 $SCRIPT_DIR/postprocess/plot_xve_occupancy.py $SCRIPT_DIR/tmp/merged $SCRIPT_DIR/plots/xve-occupancy $single_plot
python3 $SCRIPT_DIR/postprocess/resume.py $SCRIPT_DIR/tmp/merged $SCRIPT_DIR/plots/resume.txt
python3 $SCRIPT_DIR/postprocess/resume.py $SCRIPT_DIR/tmp/merged $SCRIPT_DIR/plots/resume.csv
python3 $SCRIPT_DIR/postprocess/speedup_plot.py $SCRIPT_DIR/plots/resume.csv $SCRIPT_DIR/plots/speedup/speedup-simd32.pdf 32 2> /dev/null

# Deactivate virtual environment
if [ "$no_venv" = false ]; then
  echo "[*] Deactivating virtual environment..."
  deactivate
fi

echo "[*] Done"
