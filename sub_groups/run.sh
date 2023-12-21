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
mkdir -p $SCRIPT_DIR/tmp/logs
mkdir -p $SCRIPT_DIR/tmp/vtune-reports

echo "vec_add"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/vec_add \
  --size=1000000 --num-iters=100000 --device=gpu --num-runs=$runs -- > $SCRIPT_DIR/tmp/logs/VectorAddition.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/VectorAddition.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "matrix_mul"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/matrix_mul \
  --size=2048 --num-iters=5 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MatrixMul.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MatrixMul.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "nbody"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/nbody \
  --size=8192 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/NBody.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/NBody.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "scalar_prod"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/scalar_prod \
  --size=2097152 --num-iters=100000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/ScalarProd.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/ScalarProd.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "sobel"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/sobel \
  --size=1024 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Sobel.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/Sobel.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "median"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/median \
  --size=2048 --num-iters=1000 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/logs/Median.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/Median.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "lin_reg_coeff"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/lin_reg_coeff \
  --size=3072 --num-iters=1000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/LinRegCoeff.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/LinRegCoeff.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "kmeans"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/kmeans \
  --size=32768 --num-iters=50000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/KMeans.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/KMeans.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "mol_dyn"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/mol_dyn \
  --size=60000 --num-iters=200000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MolDyn.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MolDyn.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "merse_twister"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/merse_twister \
  --size=262144 --num-iters=50000 --device=gpu --num-runs=$runs > $SCRIPT_DIR/logs/MerseTwister.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/MerseTwister.csv
rm -rf $SCRIPT_DIR/tmp/r000gh


echo "[*] Done"