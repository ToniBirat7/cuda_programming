#include <iostream>
#include <stdio.h> // Required for printf (or <cstdio> in modern C++)

using namespace std;

void implicit_cast() {

    int a = 10;
    
    // %d is the format specifier for a standard integer (Decimal)
    printf("a:%d\n", a);

    double b = a;
    
    // %f is the format specifier for a float/double.
    // The ".1" tells it to print exactly 1 decimal place.
    printf("b:%.1f\n", b);
}

void c_style_cast() {
    double pi = 3.14;
    
    int int_pi = (int)pi;
    printf("pi: %d\n", int_pi);
}

int main() {
    printf("Implicit Casting: \n");
    implicit_cast();

    printf("C Style Casting: \n");
    c_style_cast();

    return 0;
}