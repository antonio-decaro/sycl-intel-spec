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
  --size=134217728 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/VectorAddition.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/VectorAddition.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "matrix_mul"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/matrix_mul \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/MatrixMul.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/MatrixMul.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "spmm"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/spmm \
  --seed=0 --no-verification \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/SpMM.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/SpMM.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "spgemm"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/spgemm \
  --seed=0 --no-verification \
  --size=4096 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/SpGEMM.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/SpGEMM.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "nbody"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/nbody \
  --size=8192 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/NBody.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/NBody.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "scalar_prod"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/scalar_prod \
  --size=8388608 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/ScalarProd.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/ScalarProd.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "sobel"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/sobel \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/tmp/logs/Sobel.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/Sobel.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "median"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/median \
  --size=4096 --num-iters=1 --device=gpu --no-verification --num-runs=$runs > $SCRIPT_DIR/tmp/logs/Median.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/Median.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "lin_reg_coeff"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/lin_reg_coeff \
  --size=67108864 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/LinRegCoeff.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/LinRegCoeff.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "kmeans"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/kmeans \
  --size=67108864 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/KMeans.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/KMeans.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "mol_dyn"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/mol_dyn \
  --size=33554432 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/MolDyn.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/MolDyn.csv
rm -rf $SCRIPT_DIR/tmp/r000gh

echo "merse_twister"
vtune -collect gpu-hotspots -r $SCRIPT_DIR/tmp/r@@@{at} -- $BENCH_DIR/merse_twister \
  --size=134217728 --num-iters=1 --device=gpu --num-runs=$runs > $SCRIPT_DIR/tmp/logs/MerseTwister.log
vtune -report hotspots -r $SCRIPT_DIR/tmp/r000gh -group-by computing-task -format csv -report-output $SCRIPT_DIR/tmp/vtune-reports/MerseTwister.csv
rm -rf $SCRIPT_DIR/tmp/r000gh


echo "[*] Done"