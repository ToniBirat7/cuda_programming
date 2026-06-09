#include <stdio.h>

// You don't need to type __host__, but this is exactly what it means!
__host__ void printHelloFromCPU() {
    printf("I am running on the AMD Ryzen CPU!\n");
}

int main() {
    printHelloFromCPU(); // CPU calls a CPU function. Perfectly fine.
    return 0;
}