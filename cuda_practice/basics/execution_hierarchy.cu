#include <iostream>
#include <cuda_runtime.h>

using namespace std;

// Suppose:

// A = [1,2,3,4,5,6,7,8,9,10,11,12]
// B = [10,20,30,40,50,60,70,80,90,100,110,120]

// We want:

// C = A + B

// Result:

// C = [11,22,33,44,55,66,77,88,99,110,121,132]

__global__ void addVectors(int *A, int *B, int *C, int N)
{
    // Local thread ID inside block
    int tid = threadIdx.x;

    // Block ID inside grid
    int bid = blockIdx.x;

    // Number of threads in each block
    int blockSize = blockDim.x;

    // Global thread ID (The Golden Formula)
    int gid = bid * blockSize + tid;

    // GUARD CLAUSE: Ensure thread does not access out-of-bounds memory
    if (gid < N) 
    {
        // Perform addition
        C[gid] = A[gid] + B[gid];

        // Print thread information
        printf("Block ID: %d | Thread ID: %d | Global ID: %d | A[%d]=%d + B[%d]=%d = %d\n",
               bid, tid, gid,
               gid, A[gid],
               gid, B[gid],
               C[gid]);
    }
}

int main() {
const int N = 12;
    size_t bytes = N * sizeof(int);

    // Host (CPU) Arrays
    int h_A[N] = {1,2,3,4,5,6,7,8,9,10,11,12};
    int h_B[N] = {10,20,30,40,50,60,70,80,90,100,110,120};
    int h_C[N];

    // Device (GPU) Pointers
    int *d_A, *d_B, *d_C;

    // Allocate GPU memory
    // Pass the address of the pointer that is in the RAM, that will hold the address of the allocated memory in the VRAM
    // We need to always pass the address (&) of the pointer, not only the variable otherwise pass by value

    // Because d_A is already a pointer, taking the address of it (&d_A) creates a Double Pointer (int**). cudaMalloc requires a double pointer so it can modify the original single pointer
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    // The pointer on the RAM just stores of allocated address of the VRAM
    // If we try to access or read using that address on GPU d_A[0] = 5; // CRASH! SEGMENTATION FAULT! 

    // Your CPU looks at the paper (d_A), sees the address 0xGPU_999, and tries to reach out and put the number 5 in it. But the CPU Operating System steps in and says: "Hey! 0xGPU_999 is across the PCIe highway inside the graphics card. You don't have physical access to touch that memory from here!"

    // That is exactly why you are forced to use cudaMemcpy(..., cudaMemcpyHostToDevice). You have to hire a delivery truck to carry the number 5 across the PCIe highway to the VRAM address stored on your piece of paper.

    // Copy the CPU data to the memory just allocated memory address, i.e. h_A (CPU) => d_A (GPU)
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Launch kernel (3 Blocks, 4 Threads per Block)
    addVectors<<<3, 4>>>(d_A, d_B, d_C, N);

    // Wait for the GPU to finish 
    cudaDeviceSynchronize();

    // Copy result that is in the GPU, and the pointer to that address is saved by d_C which is currently in the CPU. So we need to move the data that d_C is pointing in the GPU to h_C in CPU
    cudaMemcpy(h_C, d_C, bytes, cudaMemcpyDeviceToHost);

    // Print final result 
    cout << "\nFinal Output:\n";
    for (int i = 0; i < N; i++) {
        cout << h_C[i] << " ";
    }
    cout << "\n";

    // Free memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}