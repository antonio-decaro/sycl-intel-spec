#!/bin/bash

logscale=False
time_unit="s"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --logscale*)
      logscale=True
      shift
      ;;
    --time_unit=*)
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

python3 $SCRIPT_DIR/postprocess/parse.py $SCRIPT_DIR/logs $SCRIPT_DIR/parsed
python3 $SCRIPT_DIR/postprocess/plot.py $SCRIPT_DIR/parsed $SCRIPT_DIR/plots $logscale $time_unit

# Deactivate virtual environment
deactivate
echo "[*] Done"
