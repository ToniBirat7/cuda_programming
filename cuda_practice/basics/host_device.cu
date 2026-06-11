#include <stdio.h>

// You don't need to type __host__, but this is exactly what it means!
__host__ void printHelloFromCPU() {
    printf("I am running on the AMD Ryzen CPU!\n");
}

// __device__ is for GPU-only functions. The CPU can't call this directly. If we call this from main function we will get an error because the main function is running on the CPU, and it cannot directly call a function that is meant to run on the GPU. The GPU functions need to be called from a kernel, which is a special type of function that runs on the GPU and can be launched from the CPU.
__device__ void printHelloFromGPU() {
    printf("I am running on the NVIDIA GPU!\n");
}

// Kernel functions are the bridge between CPU and GPU. They are defined with __global__ and can be called from the CPU, but they execute on the GPU. Inside a kernel, you can call __device__ functions, but you cannot call __host__ functions directly.

__global__ void callGPUFunction() {
    printHelloFromGPU(); // This is fine because we are inside a kernel, which runs on the GPU.
}

int main() {
    printHelloFromCPU(); // CPU calls a CPU function. Perfectly fine.
    // printHelloFromGPU(); // ERROR: CPU cannot call a GPU function directly!, because the main function is running on the CPU, and it cannot directly call a function that is meant to run on the GPU. The GPU functions need to be called from a kernel, which is a special type of function that runs on the GPU and can be launched from the CPU.

    // To call the GPU function, we need to launch a kernel. A kernel is a function that runs on the GPU and can be called from the CPU. We can create a kernel using __global__ and then launch it with the <<<>>> syntax.

    // Calling the GPU Kernel from CPU
    callGPUFunction<<<1, 1>>>(); // Launching the kernel with 1 block and 1 thread. This will execute the callGPUFunction on the GPU, which in turn will call printHelloFromGPU() and print the message from the GPU.

    // Sync the CPU and GPU to ensure the GPU has finished executing before we exit the program. This is important because CUDA operations are asynchronous, and we want to make sure all GPU work is done before we exit.
    cudaDeviceSynchronize();
    return 0;
}