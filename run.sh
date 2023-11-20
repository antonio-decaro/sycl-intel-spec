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

# Running benchmarks
echo "[*] Running benchmarks..."

mkdir -p $SCRIPT_DIR/logs

echo "vec_add"
$SCRIPT_DIR/build/vec_add \
  --size=1000000 --num-iters=100000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/VectorAddition.log
echo "matrix_mul"
$SCRIPT_DIR/build/matrix_mul \
  --size=2048 --num-iters=5 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MatrixMul.log
echo "nbody"
$SCRIPT_DIR/build/nbody \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/NBody.log
echo "scalar_prod"
$SCRIPT_DIR/build/scalar_prod \
  --size=2097152 --num-iters=100000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/ScalarProd.log
echo "sobel"
$SCRIPT_DIR/build/sobel \
  --size=1536 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Sobel.log

echo "[*] Done"