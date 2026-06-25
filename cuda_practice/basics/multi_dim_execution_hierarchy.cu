#include <iostream>
#include <vector>
#include <stdio.h>

// ---------------------------------------------------------
// DEVICE FUNCTION: Clamp values to stay between 0 and 255 (Valid pixel colors)
// ---------------------------------------------------------
__device__ int clampPixel(int val) {
    if (val < 0) return 0;
    if (val > 255) return 255;
    return val;
}

// ---------------------------------------------------------
// GLOBAL FUNCTION: The 2D Image Kernel
// ---------------------------------------------------------
__global__ void brightenImage2D(int *d_image_in, int *d_image_out, int width, int height, int brightness) {
    
    // 1. Find the 2D X and Y position of this thread on the screen
    int x = (blockIdx.x * blockDim.x) + threadIdx.x; // Column (Width)
    int y = (blockIdx.y * blockDim.y) + threadIdx.y; // Row (Height)

    // 2. The 2D Guard Clause!
    // Since images might not be perfectly divisible by 16, we MUST check both X and Y.
    if (x < width && y < height) {
        
        // 3. The Golden 2D-to-1D Formula
        // Physical memory is always a 1D straight line. We flatten our 2D coordinates.
        int index = (y * width) + x;

        // 4. Do the work
        int current_pixel = d_image_in[index];
        int new_pixel = current_pixel + brightness;
        
        // 5. Save the clamped result
        d_image_out[index] = clampPixel(new_pixel);
    }
}

// ---------------------------------------------------------
// MAIN: The Orchestrator
// ---------------------------------------------------------
int main() {
    // 1. Define the screen dimensions
    int width = 1920;
    int height = 1080;
    size_t num_pixels = width * height; // 2,073,600 pixels
    size_t bytes = num_pixels * sizeof(int); // ~8.2 Megabytes

    // 2. Setup Host (CPU) Memory
    // Let's pretend the whole image is dark gray (color code 50)
    std::vector<int> h_image_in(num_pixels, 50); 
    std::vector<int> h_image_out(num_pixels, 0); 

    // Let's manually set one specific pixel to test it later
    // We set Pixel at [Row 10, Col 20] to 250
    h_image_in[(10 * width) + 20] = 250; 

    // 3. Setup Device (GPU) Memory
    int *d_image_in, *d_image_out;
    cudaMalloc(&d_image_in, bytes);
    cudaMalloc(&d_image_out, bytes);

    // 4. Copy CPU data to GPU
    cudaMemcpy(d_image_in, h_image_in.data(), bytes, cudaMemcpyHostToDevice);

    // ---------------------------------------------------------
    // THE 2D MAGIC: Setting up dim3
    // ---------------------------------------------------------
    // We build a 2D Room (Block) of 16x16 workers (256 threads total per block)
    dim3 threadsPerBlock(16, 16); // z is automatically 1

    // We build a 2D Factory (Grid) to cover the 1920x1080 screen.
    // We add (16 - 1) before dividing to round UP, ensuring we cover the edges!
    int blocks_x = (width + threadsPerBlock.x - 1) / threadsPerBlock.x;
    int blocks_y = (height + threadsPerBlock.y - 1) / threadsPerBlock.y;
    
    dim3 blocksPerGrid(blocks_x, blocks_y); // z is automatically 1

    printf("Image Size: %d x %d\n", width, height);
    printf("Factory Grid: %d blocks wide, %d blocks tall\n", blocksPerGrid.x, blocksPerGrid.y);
    printf("Total Blocks Launched: %d\n\n", blocksPerGrid.x * blocksPerGrid.y);

    // 5. Launch the 2D Kernel (Adding +50 Brightness to every pixel)
    brightenImage2D<<<blocksPerGrid, threadsPerBlock>>>(d_image_in, d_image_out, width, height, 50);

    // Wait for GPU
    cudaDeviceSynchronize();

    // 6. Copy GPU data back to CPU
    cudaMemcpy(h_image_out.data(), d_image_out, bytes, cudaMemcpyDeviceToHost);

    // 7. Verification
    printf("--- Verification ---\n");
    printf("Normal Pixel   (Should be 50 + 50 = 100):  Result = %d\n", h_image_out[0]);
    
    // Pixel [Row 10, Col 20] was 250. 250 + 50 = 300. 
    // But our clampPixel() should lock it to 255!
    int test_pixel = h_image_out[(10 * width) + 20];
    printf("Bright Pixel   (Should be clamped to 255): Result = %d\n", test_pixel);

    // 8. Clean up
    cudaFree(d_image_in);
    cudaFree(d_image_out);

    return 0;
}