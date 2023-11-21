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

mkdir -p $SCRIPT_DIR/logs

echo "vec_add"
$BENCH_DIR/vec_add \
  --size=1000000 --num-iters=100000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/VectorAddition.log
echo "matrix_mul"
$BENCH_DIR/matrix_mul \
  --size=2048 --num-iters=5 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MatrixMul.log
echo "nbody"
$BENCH_DIR/nbody \
  --size=8192 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/NBody.log
echo "scalar_prod"
$BENCH_DIR/scalar_prod \
  --size=2097152 --num-iters=100000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/ScalarProd.log
echo "sobel"
$BENCH_DIR/sobel \
  --size=1024 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Sobel.log

echo "[*] Done"