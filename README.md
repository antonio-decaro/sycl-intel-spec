# SYCL Intel Specialization
Repository for running specialization tests over Intel GPUs.
## Requirements

## Repeating experiments
### 1. Building the benchmark
Run `build.sh` to build the benchmarks.

Required arguments:
- `--cxx-compiler=` the path to the DPC++ compiler;
- `--intel-arch=` the name of the intel GPU architecture (e.g. acm-g10);

Then navigate to any directory to stress the corresponding feature.

Optional arguments:
- `--cxx_flags=` additional flags to the DPC++ compiler;
- `--enable-fp64` enables fp64 support;
- `--disable-sg8` disables sub group size 8;
- `--disable-compute-benchmarks` avoid building computing benchmarks;
- `--disable-memory-benchmarks` avoid building memory benchmarks;
### 2. Executing the benchmarks
Run `run.sh` to execute the benchmarks.

Optional Parameters:
- `--runs=` the number of executions;
### 3. Drawing plots
Run `process.sh` to draw the plots.

Optional Arguments:
- `--logscale` use logscale to draw Y axis of the chart;
- `--time_unit=<arg>` arg can be `s` (default), `ms`, `us`, or `ns`;