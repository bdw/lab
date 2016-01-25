#include <stdio.h>
#include <stdlib.h>
extern char * roman_numeral(int);

int main(int argc, char **argv) {
    int i = 42;
    char *numeral;
    if (argc > 1) {
        i = atoi(argv[1]);
    }
    numeral = roman_numeral(i);
    puts(numeral);
}
