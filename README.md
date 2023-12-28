# SYCL Intel Specialization
Repository for running specialization tests over Intel GPUs with SYCL.

## Requirements
TODO

## Building experiments
You need to build the scripts before navigating in each sub-directory.

To do that, run `build.sh` to build the benchmarks.

Required arguments:
- `--cxx-compiler=` the path to the DPC++ compiler;

Then navigate to any directory to stress the corresponding feature.

Optional arguments:
- `--cxx-flags=` additional flags to the DPC++ compiler;
- `--enable-fp64` enables fp64 support;
- `--disable-sg8` disables sub group size 8;
- `--disable-compute-benchmarks` avoid building computing benchmarks;
- `--disable-memory-benchmarks` avoid building memory benchmarks;

## Post Building

You are free to navigate in each sub-directory to test one or more covered aspects of this repository.