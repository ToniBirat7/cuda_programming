#include <iostream>
#include <vector>
#include <stdio.h>

// ---------------------------------------------------------
// 1. HOST-ONLY: Standard CPU functions
// ---------------------------------------------------------
// If we don't put a tag, it defaults to __host__. 
// We use this to initialize our CPU data safely.
void generateRawSignals(std::vector<int>& cpu_array, int num_elements) {
    for (int i = 0; i < num_elements; i++) {
        // Generate a random signal between -50 and 150
        cpu_array[i] = (rand() % 200) - 50; 
    }
}

// ---------------------------------------------------------
// 2. HOST & DEVICE: The Utility Function
// ---------------------------------------------------------
// Clamping keeps a number within a strict Min/Max range.
// We tag it with BOTH because we want to be able to use it 
// on the CPU for testing, AND on the GPU for massive processing!
__host__ __device__ int clamp(int val, int min_val, int max_val) {
    if (val < min_val) return min_val;
    if (val > max_val) return max_val;
    return val;
}

// ---------------------------------------------------------
// 3. DEVICE-ONLY: The GPU Internal Helper
// ---------------------------------------------------------
// This math is an internal step of our GPU pipeline.
// The CPU has no business calling this function directly.
__device__ int boostSignal(int val) {
    // Arbitrary math: Multiply the signal by 3
    return val * 3;
}

// ---------------------------------------------------------
// 4. GLOBAL: The CUDA Kernel (The CPU-to-GPU Bridge)
// ---------------------------------------------------------
// This is called by the CPU, but executed by thousands of GPU threads.
__global__ void processSignalsKernel(int* d_data, int n) {
    // 1. Calculate this specific thread's Global ID
    int tid = (blockIdx.x * blockDim.x) + threadIdx.x;

    // 2. Boundary Check: Ensure we don't process out of bounds!
    if (tid < n) {
        int raw_value = d_data[tid];

        // 3. Thread calls the __device__ function
        int boosted = boostSignal(raw_value);

        // 4. Thread calls the __host__ __device__ function (Clamp to 0-255)
        int final_value = clamp(boosted, 0, 255);

        // 5. Write the result back to GPU VRAM
        d_data[tid] = final_value;
    }
}

// ---------------------------------------------------------
// 5. MAIN: The Orchestrator (Runs on CPU)
// ---------------------------------------------------------
int main() {
    // Let's process 1 Million signals! (Using 1ULL to prevent overflow)
    size_t N = 1ULL << 20; 
    size_t bytes = N * sizeof(int);

    // --- STEP 1: CPU Operations ---
    printf("1. Generating %zu signals on CPU RAM...\n", N);
    std::vector<int> h_signals(N);
    generateRawSignals(h_signals, N);

    // Let's test our __host__ __device__ function on the CPU just to prove it works!
    int test_val = clamp(500, 0, 255);
    printf("   -> CPU tested clamp(500, 0, 255). Result: %d\n", test_val);

    // --- STEP 2: Allocate GPU VRAM ---
    printf("2. Allocating %zu bytes of VRAM on RTX 3060...\n", bytes);
    int* d_signals;
    cudaMalloc(&d_signals, bytes);

    // --- STEP 3: Copy Data to GPU ---
    printf("3. Copying data over PCIe Bus (Host -> Device)...\n");
    cudaMemcpy(d_signals, h_signals.data(), bytes, cudaMemcpyHostToDevice);

    // --- STEP 4: Launch Kernel ---
    int THREADS = 256;
    int BLOCKS = (N + THREADS - 1) / THREADS; // Golden Formula for blocks!
    
    printf("4. Launching GPU Kernel with %d blocks and %d threads per block...\n", BLOCKS, THREADS);
    processSignalsKernel<<<BLOCKS, THREADS>>>(d_signals, N);

    // Make CPU wait for the GPU to finish its millions of calculations
    cudaDeviceSynchronize();

    // --- STEP 5: Copy Results Back to CPU ---
    printf("5. Copying data back over PCIe Bus (Device -> Host)...\n");
    cudaMemcpy(h_signals.data(), d_signals, bytes, cudaMemcpyDeviceToHost);

    // --- STEP 6: Verify and Clean Up ---
    printf("6. Printing the first 5 processed signals:\n");
    for (int i = 0; i < 5; i++) {
        printf("   Signal [%d]: %d\n", i, h_signals[i]);
    }

    // Free the GPU memory (CRUCIAL to prevent memory leaks!)
    cudaFree(d_signals);
    printf("7. GPU VRAM freed. Done!\n");

    return 0;
}