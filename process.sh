#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# check if venv folder exists
if [ ! -d "$SCRIPT_DIR/postprocess/.venv" ]; then
  echo "[*] Creating virtual environment..."
  python3 -m venv $SCRIPT_DIR/postprocess/.venv
  source $SCRIPT_DIR/postprocess/.venv/bin/activate
  pip3 install -r $SCRIPT_DIR/postprocess/requirements.txt
else
  echo "[*] Virtual environment already exists"
fi

echo "[*] Postprocessing logs..."
python3 $SCRIPT_DIR/postprocess/parse.py $SCRIPT_DIR/logs $SCRIPT_DIR/parsed
# TODO the rest of the postprocessing
echo "[*] Done"
