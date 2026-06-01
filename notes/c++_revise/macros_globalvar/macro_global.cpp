#include <iostream>

#define PI 3.14159
#define NUM_THREADS 256
#define MULTIPLY(a, b) (a * b) // Function-like macro

int main() {
    double circle = PI * 2; 
    int total = MULTIPLY(10, 5);
    return 0;
}