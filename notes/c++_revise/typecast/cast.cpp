#include <iostream>
#include <stdio.h> // Required for printf (or <cstdio> in modern C++)

using namespace std;

int main() {
    int a = 10;
    
    // %d is the format specifier for a standard integer (Decimal)
    printf("a:%d\n", a);

    double b = a;
    
    // %f is the format specifier for a float/double.
    // The ".1" tells it to print exactly 1 decimal place.
    printf("b:%.1f\n", b);

    return 0;
}