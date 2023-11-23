cmake_minimum_required(VERSION 3.17)
project(LevelZeroTest VERSION 0.1 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(LevelZero REQUIRED)

# set compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsycl -fsycl-targets=intel_gpu_acm_g10")

add_executable(sub_devices src/sub_devices.cpp)
target_link_libraries(sub_devices PRIVATE LevelZero::LevelZero)
target_compile_features(sub_devices PRIVATE cxx_std_17)
