#include <iostream>

using namespace std;

void matrix_2d_array() {

    int arr[][4] = {{1,2,3,4}, {5,6,7,8}};

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j <=3; j++) {
            printf("%d ", arr[i][j]);
        }
        printf("\n");
    }
}

void matrix() {
    int arr1[] = {1,2,3,4};
    int arr2[] = {5,6,7,8};

    int* ptr1 = arr1; // Pointer to first array
    int* ptr2 = arr2; // Pointer to second array

    int* matrix[] = {ptr1, ptr2}; // Array of pointers that represents a matrix

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j <=3; j++) {
            printf("%d ", *matrix[i]++);
        }
        printf("\n");
    }
}

int main() {
    matrix();
    matrix_2d_array();
}