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
    // We need to always pass the address of the pointer, not only the variable otherwise pass by value

    // Because d_A is already a pointer, taking the address of it (&d_A) creates a Double Pointer (int**). cudaMalloc requires a double pointer so it can modify the original single pointer
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);
}