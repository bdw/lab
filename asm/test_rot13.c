#include <stdio.h>
#include <stdlib.h>

extern char * rot13_encrypt(char * data);

int main (int argc, char **argv) {
    char *result;
    if (argc < 2) {
        printf("Usage: %s <message>\n", argv[0]);
        return 1;
    }
    result = rot13_encrypt(argv[1]);
    puts(result);
    free(result);
    return 0;
}
