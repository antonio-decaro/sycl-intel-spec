# Sub Group Analysis
This directory contains the scripts for analyzing memory bandwidth of the Intel GPU.

## Requirements
To run this you need Intel Advisor tool to retreive information related to roofline.
You can download the software [here](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html).

Then you might run the command `/opt/intel/oneapi/setvars.sh`.

## Running
You need to run the build script in the root folder first.
Then you an proceede with the following instructions.

### 1. Executing the benchmarks
Run `run.sh` to execute the benchmarks.
If it fails you can try executing with `sudo`.

Optional Parameters:
- `--runs=` the number of executions;
