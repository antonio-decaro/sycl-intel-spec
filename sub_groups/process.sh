#!/bin/bash

logscale=False
time_unit="s"
single_plot=False

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
    *)
      echo "Invalid argument: $1"
      return 1 2>/dev/null
      exit 1
      ;;
  esac
done


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# check if venv folder exists
if [ ! -d "$SCRIPT_DIR/postprocess/.venv" ]; then
  echo "[*] Creating virtual environment..."
  python3 -m venv $SCRIPT_DIR/postprocess/.venv
  pip3 install -r $SCRIPT_DIR/postprocess/requirements.txt
else
  echo "[*] Virtual environment already exists"
fi

source $SCRIPT_DIR/postprocess/.venv/bin/activate

echo "[*] Postprocessing logs..."

mkdir -p $SCRIPT_DIR/parsed
mkdir -p $SCRIPT_DIR/merged
mkdir -p $SCRIPT_DIR/plots
mkdir -p $SCRIPT_DIR/plots/time
mkdir -p $SCRIPT_DIR/plots/xve-utilization

python3 $SCRIPT_DIR/postprocess/parse.py $SCRIPT_DIR/logs $SCRIPT_DIR/parsed
python3 $SCRIPT_DIR/postprocess/merge.py $SCRIPT_DIR/parsed $SCRIPT_DIR/tmp $SCRIPT_DIR/merged
python3 $SCRIPT_DIR/postprocess/plot_time.py $SCRIPT_DIR/merged $SCRIPT_DIR/plots/time $logscale $time_unit $single_plot
python3 $SCRIPT_DIR/postprocess/plot_xve_utilization.py $SCRIPT_DIR/merged $SCRIPT_DIR/plots/xve-utilization $single_plot
python3 $SCRIPT_DIR/postprocess/plot_xve_occupancy.py $SCRIPT_DIR/merged $SCRIPT_DIR/plots/xve-occupancy $single_plot

# Deactivate virtual environment
deactivate
echo "[*] Done"
