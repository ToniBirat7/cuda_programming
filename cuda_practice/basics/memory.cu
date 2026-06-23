#include <iostream>
#include <vector>

int main() {
    // 1. Define our image size
    int N = 4000; // 4000 width x 4000 height
    size_t num_pixels = N * N; // 16,000,000 pixels
    size_t bytes = num_pixels * sizeof(float); // ~64 Megabytes of data

    // ==========================================
    // CPU PHASE: Load the Image
    // ==========================================
    // Create the image array in CPU RAM
    std::vector<float> h_image_in(num_pixels, 0.5f); // Pretend we loaded a gray image
    std::vector<float> h_image_out(num_pixels);      // Empty array to hold the result

    // ==========================================
    // GPU LOGISTICS PHASE 1: Allocate VRAM
    // ==========================================
    float *d_image_in, *d_image_out;

    // We need 64 MB for the original image, and 64 MB for the new brightened image
    cudaMalloc(&d_image_in, bytes);
    cudaMalloc(&d_image_out, bytes);

    // ==========================================
    // GPU LOGISTICS PHASE 2: Ship the Data
    // ==========================================
    std::cout << "Shipping 64MB Image to GPU...\n";
    // Send the raw image from Host (CPU) to Device (GPU)
    cudaMemcpy(d_image_in, h_image_in.data(), bytes, cudaMemcpyHostToDevice);

    // ==========================================
    // COMPUTE PHASE: The Magic Happens
    // ==========================================
    // (Imagine we launch a kernel here that adds +0.2f brightness to every pixel)
    // brightenImageKernel<<<Blocks, Threads>>>(d_image_in, d_image_out, num_pixels);
    
    // Here is a Device-to-Device example! 
    // Let's pretend the kernel failed, and we just want to copy the original 
    // image straight into the output buffer entirely within the GPU VRAM:
    cudaMemcpy(d_image_out, d_image_in, bytes, cudaMemcpyDeviceToDevice);

    // ==========================================
    // GPU LOGISTICS PHASE 3: Retrieve the Product
    // ==========================================
    std::cout << "Retrieving finished Image from GPU...\n";
    // Send the finished, brightened image from Device (GPU) back to Host (CPU)
    cudaMemcpy(h_image_out.data(), d_image_out, bytes, cudaMemcpyDeviceToHost);

    // ==========================================
    // GPU LOGISTICS PHASE 4: Clean Up
    // ==========================================
    // We saved our result to the CPU, so the GPU doesn't need the memory anymore.
    cudaFree(d_image_in);
    cudaFree(d_image_out);

    std::cout << "VRAM Freed. Image ready to save to hard drive!\n";

    return 0;
}