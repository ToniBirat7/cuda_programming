#include <stdio.h>
using namespace std;

int main() {
    int* ptr = nullptr;

    printf("1. Initial prt value: %p\n", (void*)ptr);

    // Check for nullptr
    if (ptr != nullptr) {
    printf("2. ptr is NULL cannot dereference");

    }
    else {
        // ptr is null
    }
}