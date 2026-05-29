#include <iostream>

using namespace std;

void matrix() {
    int arr1[] = {1,2,3,4};
    int arr2[] = {5,6,7,8};

    int* ptr1 = arr1; // Pointer to first array
    int* ptr2 = arr2; // Pointer to second array

    int* matrix[] = {ptr1, ptr2}; // Array of pointers that represents a matrix
}

int main() {

}