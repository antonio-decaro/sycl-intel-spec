#!/bin/bash

CXX_COMPILER=""
CXX_FLAGS=""
intel_arch=""
enable_fp64_benchmarks=0


# Build the project
echo "[*] Building the project..."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cxx_compiler=*)
      CXX_COMPILER="${1#*=}"
      shift
      ;;
    --cxx_flags=*)
      CXX_FLAGS="${1#*=}"
      shift
      ;;
    --intel_arch=*)
      intel_arch="${1#*=}"
      shift
      ;;
    --enable_fp64*)
      enable_fp64_benchmarks=1
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
      -S $SCRIPT_DIR/sycl-bench -B $SCRIPT_DIR/build

cmake --build $SCRIPT_DIR/build -j"

