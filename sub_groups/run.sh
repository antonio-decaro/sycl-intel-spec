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
mkdir -p $SCRIPT_DIR/tmp

echo "vec_add"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/vec_add \
  --size=1000000 --num-iters=100000 --device=gpu --num-runs=$runs -- > $SCRIPT_DIR/logs/VectorAddition.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/VectorAddition.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "matrix_mul"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/matrix_mul \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MatrixMul.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MatrixMul.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "nbody"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/nbody \
  --size=8192 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/NBody.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/NBody.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "scalar_prod"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/scalar_prod \
  --size=8388608 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/ScalarProd.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/ScalarProd.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "sobel"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/sobel \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Sobel.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/Sobel.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "median"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/median \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Median.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/Median.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "lin_reg_coeff"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/lin_reg_coeff \
  --size=8388608 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/LinRegCoeff.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/LinRegCoeff.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "kmeans"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/kmeans \
  --size=16777216 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/KMeans.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/KMeans.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "mol_dyn"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/mol_dyn \
  --size=16777216 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MolDyn.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MolDyn.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "merse_twister"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/merse_twister \
  --size=33554432 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MerseTwister.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MerseTwister.csv
rm -rf $SCRIPT_DIR/tmp/r000gh


echo "[*] Done"