#include <iostream>
#include <vector>
#include <math.h>

// ---------------------------------------------------------
// 1. THE KERNEL (Runs on the GPU)
// ---------------------------------------------------------
// __global__ tells the compiler this is a GPU function called from the CPU
__global__ void vectorAdd(const int *a, const int *b, int *c, int n) {
    // Calculate the global thread ID
    int tid = (blockIdx.x * blockDim.x) + threadIdx.x;

    // Boundary check: Make sure we don't read outside our array bounds!
    // (Sometimes we spawn more threads than array elements)
    if (tid < n) {
        c[tid] = a[tid] + b[tid];
    }
}

// ---------------------------------------------------------
// 2. MAIN FUNCTION (Runs on the CPU)
// ---------------------------------------------------------
int main() {
    // Let's create arrays with 2^16 elements (65,536 elements)
    int n = 1 << 16; 
    size_t bytes = n * sizeof(int);

    // --- STEP 1: Allocate Host (CPU) Memory ---
    // Using std::vector for easy memory management on the CPU
    std::vector<int> h_a(n);
    std::vector<int> h_b(n);
    std::vector<int> h_c(n);

    // Initialize the arrays with random numbers
    for (int i = 0; i < n; i++) {
        h_a[i] = rand() % 100;
        h_b[i] = rand() % 100;
    }

    // --- STEP 2: Allocate Device (GPU) Memory ---
    // We create pointers, then use cudaMalloc to allocate VRAM on your RTX 3060
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // --- STEP 3: Copy Data from Host (CPU) to Device (GPU) ---
    // Syntax: cudaMemcpy(destination, source, size_in_bytes, direction)
    cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice);

    // --- STEP 4: Define Grid and Block Dimensions ---
    int NUM_THREADS = 256; // Standard starting point (256 threads per block)
    
    // Calculate number of blocks needed. 
    // We add (NUM_THREADS - 1) before dividing to round up!
    // E.g., if we had 257 items, we need 2 blocks, not 1.
    int NUM_BLOCKS = (n + NUM_THREADS - 1) / NUM_THREADS; 

    // --- STEP 5: Launch the Kernel ---
    // <<< Blocks, Threads >>>
    vectorAdd<<<NUM_BLOCKS, NUM_THREADS>>>(d_a, d_b, d_c, n);

    // Wait for GPU to finish
    cudaDeviceSynchronize();

    // --- STEP 6: Copy Results Back to Host (CPU) ---
    cudaMemcpy(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost);

    // --- STEP 7: Verify the Result ---
    // Let's check if the GPU did the math right!
    bool error = false;
    for (int i = 0; i < n; i++) {
        if (h_c[i] != h_a[i] + h_b[i]) {
            std::cout << "Error at index " << i << "! " 
                      << h_a[i] << " + " << h_b[i] << " != " << h_c[i] << "\n";
            error = true;
            break; // Stop checking on first error
        }
    }
    
    if (!error) {
        std::cout << "SUCCESS! GPU added " << n << " elements correctly.\n";
    }

    // --- STEP 8: Free Device Memory ---
    // If you don't do this, you cause a memory leak in your VRAM!
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}