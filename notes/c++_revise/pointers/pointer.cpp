#include <stdio.h>
using namespace std;

int main() {
    int x = 42;
    int* p1 = &x;

    printf("P1 Address: %p\n", p1);
    printf("P1 Value: %d\n", *p1);

    int** p2 = &p1;

    printf("P2 Address: %p\n", p2);
    printf("P2 Value (Address of x): %p\n", *p2);
    printf("P2 Deref (x): %d\n", **p2);

    int*** p3 = &p2;

    printf("P3 Address: %p\n", p3);
    printf("P3 Value (Address of p1): %p\n", *p3);
    printf("P3 Deref (x): %d\n", ***p3);
}