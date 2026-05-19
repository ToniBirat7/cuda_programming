#include <stdio.h>

using namespace std;

// Void pointers

int main() {
    int num = 10;
    float fnum = 3.14;
    void* vptr;

    vptr = &num;
    printf("Integer: %d\n", *(int*)vptr); // we need to cast the void pointer to appropriate data type pointer and then dereference it to get the value of x

    vptr = &fnum;
    printf("Float: %.2f\n", *(float*)vptr); // we need to cast the void pointer to float data type pointer and then dereference it to get the value of x
}