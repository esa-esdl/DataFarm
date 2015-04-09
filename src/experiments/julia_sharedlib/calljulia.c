#include <stdio.h>

int main(int argc, char *argv[]) {
    // Allocate two array in C
    double a[1];
    double b[1];
    a[0]=5.0;
    b[0]=0.0;
    square(a,b);
    // Print result
    printf("%f squared is %f\n",a[0],b[0]);
    return 0;
}