# Sub Group Analysis
This directory contains the scripts for analyzing the sub-group featuers on the Intel GPU.

## Running
You need to run the build script in the root folder first.
Then you an proceede with the following instructions.

### 1. Executing the benchmarks
Run `run.sh` to execute the benchmarks.

Optional Parameters:
- `--runs=` the number of executions;
### 2. Drawing plots
Run `process.sh` to draw the plots.

Optional Arguments:
- `--logscale` use logscale to draw Y axis of the chart;
- `--time-unit=<arg>` arg can be `s` (default), `ms`, `us`, or `ns`;
- `--no-venv` don't use python virtual environment;