#!/bin/bash

CXX_COMPILER=""
CXX_FLAGS=""
compute_benchmarks=1
memory_benchmarks=1
input_dependent_benchmarks=1

COMPUTE_TARGETS="vec_add matrix_mul spmv spgemm nbody scalar_prod sobel median lin_reg_coeff kmeans mol_dyn merse_twister black_scholes"
MEMORY_TARGETS="host_device_bandwidth local_mem"

help()
{
    echo "Usage: ./build.sh --cxx-compier=/path/to/dpcpp --intel-arch=acm-g10
      [ --disable-compute-benchmarks ] Avoid building compute benchmarks;
      [ --disable-memory-benchmarks  ] Avoid building memory benchmarks;
      [ --disable-input-dependend-benchmarks  ] Avoid building memory benchmarks;
      [ --cxx-flags= ] Additional flags to be passed to the compiler;
      [ -h | --help ] Print this help message and exit."
    exit 2
}

# Build the project
echo "[*] Building the project..."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cxx-compiler=*)
      CXX_COMPILER="${1#*=}"
      shift
      ;;
    --cxx-flags=*)
      CXX_FLAGS="${1#*=}"
      shift
      ;;
    --disable-compute-benchmarks)
      compute_benchmarks=0
      shift
      ;;
    --disable-memory-benchmarks)
      memory_benchmarks=0
      shift
      ;;
    --disable-input-dependend-benchmarks)
      input_dependent_benchmarks=0
      shift
      ;;
    -h | --help)
      help
      exit 0
      ;;
    *)
      echo "Invalid argument: $1"
      help
      return 1 2>/dev/null
      exit 1
      ;;
  esac
done

if [ -z "$CXX_COMPILER" ]
  then
    echo "Provide the absolute path to the DPC++ compiler as --cxx_compiler argument"
    return 1 2>/dev/null
    exit 1
fi

DPCPP_CLANG=$CXX_COMPILER
BIN_DIR=$(dirname $DPCPP_CLANG)
DPCPP_LIB=$BIN_DIR/../lib/
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SYCL_IMPL="dpcpp"

echo "[*] Build sycl-bench with LevelZero backend"
cmake -DCMAKE_CXX_COMPILER=$DPCPP_CLANG \
      -DCMAKE_CXX_FLAGS="-Wno-unknown-cuda-version -Wno-linker-warnings -Wno-sycl-target $CXX_FLAGS" \
      -DENABLED_TIME_EVENT_PROFILING=ON \
      -DSYCL_IMPL=${SYCL_IMPL} \
      -DDPCPP_WITH_LZ_BACKEND=OFF \
      -S $SCRIPT_DIR/sycl-bench -B $SCRIPT_DIR/build

targets=""
if [ $compute_benchmarks -eq 1 ]
then
  targets="$targets $COMPUTE_TARGETS"
fi
if [ $memory_benchmarks -eq 1 ]
then
  targets="$targets $MEMORY_TARGETS"
fi

cmake --build $SCRIPT_DIR/build -j --target $targets

echo "[*] Benchmark buidling finished"
echo "[*] Copying the benchmark utils to the sub folders"

cp $SCRIPT_DIR/sycl-bench/Brommy.bmp $SCRIPT_DIR/sub_groups

if [ $input_dependent_benchmarks -eq 1 ]
then
echo "[*] Building sycl-bfs with LevelZero backend"
cmake -DCMAKE_CXX_COMPILER=$DPCPP_CLANG \
      -S $SCRIPT_DIR/sycl-bfs -B $SCRIPT_DIR/sycl-bfs/build
cmake --build $SCRIPT_DIR/sycl-bfs/build -j --target sycl_bfs

cp $SCRIPT_DIR/sycl-bfs/build/sycl_bfs $SCRIPT_DIR/build
fi

echo "[*] Done"