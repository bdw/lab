#include <stdio.h>

extern long fib(long n);

int main(int argc, char **argv) {
    long i;
    for (i = 0; i < 10; i++) {
        printf("%ld = %ld\n", i, fib(i));
    }
}
