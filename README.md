# SYCL Intel Specialization
Repository for running specialization tests over Intel GPUs.
## Requirements

## Repeating experiments
### 1. Building the benchmark
Run `build.sh` to build the benchmarks.

Required arguments:
- `--cxx_compiler=` the path to the DPC++ compiler;
- `--intel_arch=` the name of the intel GPU architecture (e.g. acm-g10);

Optional arguments:
- `--cxx_flags=` additional flags to the DPC++ compiler;
### 2. Executing the benchmarks
Run `run.sh` to execute the benchmarks.

Optional Parameters:
- `--runs=` the number of executions;
### 3. Drawing plots
3. Run `process.sh` to draw the plots.

Optional Arguments:
- `--logscale` use logscale to draw Y axis of the chart;