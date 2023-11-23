#!/bin/bash

CXX_COMPILER=""
CXX_FLAGS=""
intel_arch=""
enable_fp64_benchmarks=0
enable_sg8=1

targets="vec_add matrix_mul nbody scalar_prod sobel median lin_reg_coeff kmeans mol_dyn merse_twister"

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
    --intel-arch=*)
      intel_arch="${1#*=}"
      shift
      ;;
    --enable-fp64*)
      enable_fp64_benchmarks=1
      shift
      ;;
    --disable-sg8*)
      enable_sg8=0
      shift
      ;;
    *)
      echo "Invalid argument: $1"
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

if [ -z "$intel_arch" ]
  then
    echo "Provide the intel architecture as --intel_arch argument (e.g: acm-g10)"
    return 1 2>/dev/null
    exit 1
fi

DPCPP_CLANG=$CXX_COMPILER
BIN_DIR=$(dirname $DPCPP_CLANG)
DPCPP_LIB=$BIN_DIR/../lib/
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SYCL_IMPL="dpcpp"

echo "[*] Build DPC++ with LevelZero backend"
cmake -DCMAKE_CXX_COMPILER=$DPCPP_CLANG \
      -DCMAKE_CXX_FLAGS="-Wno-unknown-cuda-version -Wno-linker-warnings -Wno-sycl-target $CXX_FLAGS" \
      -DENABLED_TIME_EVENT_PROFILING=ON \
      -DSYCL_IMPL=${SYCL_IMPL} \
      -DDPCPP_WITH_LZ_BACKEND=ON \
      -DLZ_ARCH=$intel_arch \
      -DSYCL_BENCH_ENABLE_FP64_BENCHMARKS=$enable_fp64_benchmarks \
      -DSYCL_BENCH_SUPPORTS_SG_8=$enable_sg8 \
      -S $SCRIPT_DIR/sycl-bench -B $SCRIPT_DIR/build

cmake --build $SCRIPT_DIR/build -j --target $targets

echo "[*] Benchmark buidling finished"
echo "[*] Copying the benchmark utils to the sub folders"

cp $SCRIPT_DIR/sycl-bench/Brommy.bmp $SCRIPT_DIR/sub_groups

echo "[*] Done"