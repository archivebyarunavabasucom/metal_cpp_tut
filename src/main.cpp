#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>
#include <vector>
#include <iostream>

int main() {
    NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();
    auto device = MTL::CreateSystemDefaultDevice();

    NS::Error* error = nullptr;
    auto lib = device->newLibrary(
        NS::String::string("compute.metallib", NS::UTF8StringEncoding),
        &error);
    if (!lib) {
        std::cerr << "Failed to load metallib: "
            << error->localizedDescription()->utf8String() << "\n";
        return -1;
    }

    auto kernel = lib->newFunction(
        NS::String::string("array_mul", NS::UTF8StringEncoding));
    auto pipeline = device->newComputePipelineState(kernel, &error);
    if (!pipeline) {
        std::cerr << "Pipeline creation failed: "
            << error->localizedDescription()->utf8String() << "\n";
        return -1;
    }

    const uint N = 1 << 10;
    std::vector<float> A(N, 2.0f), B(N, 3.0f), C(N);
    auto bufA = device->newBuffer(A.data(), N * sizeof(float), MTL::ResourceStorageModeShared);
    auto bufB = device->newBuffer(B.data(), N * sizeof(float), MTL::ResourceStorageModeShared);
    auto bufC = device->newBuffer(N * sizeof(float), MTL::ResourceStorageModeShared);

    auto cmdQ = device->newCommandQueue();
    auto cmdB = cmdQ->commandBuffer();
    auto enc = cmdB->computeCommandEncoder();
    enc->setComputePipelineState(pipeline);
    enc->setBuffer(bufA, 0, 0);
    enc->setBuffer(bufB, 0, 1);
    enc->setBuffer(bufC, 0, 2);

    auto grid = MTL::Size(N, 1, 1);
    auto tg = MTL::Size(pipeline->maxTotalThreadsPerThreadgroup(), 1, 1);
    enc->dispatchThreads(grid, tg);
    enc->endEncoding();
    cmdB->commit();
    cmdB->waitUntilCompleted();

    memcpy(C.data(), bufC->contents(), N * sizeof(float));
    std::cout << "C[0] = " << C[0] << "  C[N-1] = " << C[N - 1] << "\n";

    pool->release();
    return 0;
}
