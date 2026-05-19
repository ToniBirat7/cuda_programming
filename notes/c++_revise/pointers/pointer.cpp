#include <stdio.h>
using namespace std;

int main() {
    int x = 42;
    int* ptr = &x;
    int** ptr2 = &ptr;
    int***ptr3 = &ptr2;

    printf("Value: %d\n", ***ptr3);
}