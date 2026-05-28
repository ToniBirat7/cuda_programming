#include <stdio.h>
#include <stdlib.h>

using namespace std;

int main() {
    int* ptr = nullptr;

    printf("1. Initial prt value: %p\n", (void*)ptr);

    // Check for nullptr
    if (ptr != nullptr) {
        printf("2. ptr is NULL cannot dereference");
        return 0;
    }

    // Allocate memory 
    ptr = new int;
    if(ptr == nullptr) {
        printf("3. Memory Allocation Failed");
    }

    int x = 4;

    ptr = &x;
    printf("4. Value of x: %d\n", *ptr);

}