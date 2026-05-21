#include <stdio.h>

using namespace std;

int main() {
    int arr[] = {1,2,3,4,5};

    printf("Arr : %p\n", arr);

    int* ptr = arr; // points to the address of the first element of arr

    // printf("Position One: %d\n", *ptr);

    // looping with array pointer 
    for (int i = 0; i < 5; i++) {
        printf("%d\n", *ptr);
        printf("%p\n", ptr);
        ptr++; // if any pointer is incremented then, it points to the next address of the array element
    }
}