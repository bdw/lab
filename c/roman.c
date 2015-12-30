#include <stdio.h>
#include <stdlib.h>

char *numeral = "IVXLCDM";
int value[]    = { 1, 5, 10, 50, 100, 500, 1000 };

int roman_number(int n, char *roman) {
    int p = 0;
    int i;
    for (i = 6; i >= 0 && n > 0; i--) {
        while (n >= value[i]) {
            roman[p++] = numeral[i];
            n         -= value[i];
        }
        if (i > 0) {
            int o = i - (i & 1 ? 1 : 2);
            if ((n + value[o]) >= value[i]) {
                roman[p++] = numeral[o];
                roman[p++] = numeral[i];
                n         += value[o];
                n         -= value[i];
            }
        }
        roman[p] = 0;
    }
    return p;
}

int main(int argc, char **argv) {
    char buffer[16];
    int i;
    for (i = 1; i < argc; i++) {
        int n = atoi(argv[i]);
        roman_number(n, buffer);
        puts(buffer);
    }
}
