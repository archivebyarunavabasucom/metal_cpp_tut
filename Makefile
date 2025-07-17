# Makefile for Metal‑cpp array multiplication

APP        := metal_array_mul
SRC_DIR    := src
BUILD_DIR  := build
METALCPPPATH := /Users/arunavabasu/metal-cpp

METAL_SRCS := $(wildcard $(SRC_DIR)/*.metal)
AIRS       := $(METAL_SRCS:$(SRC_DIR)/%.metal=$(BUILD_DIR)/%.air)
METALLIB   := $(BUILD_DIR)/compute.metallib

CXX_SRCS   := $(SRC_DIR)/mtl_implementation.cpp \
              $(SRC_DIR)/main.cpp
CXX_OBJS   := $(CXX_SRCS:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)

SDK_FRAMEWORKS := /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks

CXXFLAGS := -std=c++17 -ObjC++ -fno-objc-arc \
           -I$(METALCPPPATH) \
           -F$(SDK_FRAMEWORKS)

LDFLAGS := -framework Foundation -framework QuartzCore -framework Metal

.PHONY: all clean

all: $(BUILD_DIR)/$(APP)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile .metal shaders to .air bitcode
$(BUILD_DIR)/%.air: $(SRC_DIR)/%.metal | $(BUILD_DIR)
	xcrun -sdk macosx metal -c $< -o $@

# Build .metallib from .air files
$(METALLIB): $(AIRS)
	xcrun -sdk macosx metallib $^ -o $@

# Compile C++ source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	clang++ $(CXXFLAGS) -c $< -o $@

# Link the final executable
$(BUILD_DIR)/$(APP): $(METALLIB) $(CXX_OBJS)
	clang++ $(CXX_OBJS) -o $@ $(LDFLAGS)

run:
	cd build && ./${APP} && cd ..

clean:
	rm -rf $(BUILD_DIR)
