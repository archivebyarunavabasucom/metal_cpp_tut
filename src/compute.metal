#include <metal_stdlib>
using namespace metal;

kernel void array_mul(
    device const float* inA [[buffer(0)]],
    device const float* inB [[buffer(1)]],
    device float*      out [[buffer(2)]],
    uint index [[thread_position_in_grid]])
{
    out[index] = inA[index] * inB[index];
}
