cmake_minimum_required(VERSION 3.20)
project(array_mul LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
include_directories(/Users/arunavabasu/metal-cpp)

find_library(FOUNDATION Foundation)
find_library(QUARTZ QuartzCore)
find_library(METAL Metal)

add_executable(app
  src/mtl_implementation.cpp
  src/main.cpp
)

target_link_libraries(app
  ${FOUNDATION} ${QUARTZ} ${METAL}
)
