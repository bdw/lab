#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

void * stack_find_return_address_in_frame_posix(void *base, int size, void *top);
void bar(int *);
int main(int, char**);

void quix(int *a) {
    void *pos = stack_find_return_address_in_frame_posix(&bar, 200, a);
    void *mnl = stack_find_return_address_in_frame_posix(&main, 200, a);
    int ofs = (char*)pos - (char*)bar;
    fprintf(stderr, "pos=%"PRIx64", ofs=%d\n", pos, ofs);
    fprintf(stderr, "mnl=%"PRIx64", ofs=%d\n", mnl, (char*)mnl - (char*)main);
}


void bar(int *a) {
    fprintf(stderr, "Hello, world\n");
    quix(a);
    fprintf(stderr, "Goodbye!\n");
}

void foo(void) {
    int a = 1;
    bar(&a);
}

int main(int argc, char **argv) {
    foo();
    return 0;
}
