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
  --size=1000000 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/VectorAddition.log
echo "matrix_mul"
$BENCH_DIR/matrix_mul \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MatrixMul.log
echo "nbody"
$BENCH_DIR/nbody \
  --size=8192 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/NBody.log
echo "scalar_prod"
$BENCH_DIR/scalar_prod \
  --size=8388608 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/ScalarProd.log
echo "sobel"
$BENCH_DIR/sobel \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Sobel.log
echo "median"
$BENCH_DIR/median \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Median.log
echo "lin_reg_coeff"
$BENCH_DIR/lin_reg_coeff \
  --size=8388608 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/LinRegCoeff.log
echo "kmeans"
$BENCH_DIR/kmeans \
  --size=16777216 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/KMeans.log
echo "mol_dyn"
$BENCH_DIR/mol_dyn \
  --size=16777216 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MolDyn.log
echo "merse_twister"
$BENCH_DIR/merse_twister \
  --size=33554432 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MerseTwister.log


echo "[*] Done"