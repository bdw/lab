#include <stdio.h>

void * get_cont(void);

int main (int argc, char **argv) {
    int i = 0;

    void (*cc)(void) = get_cont();
    if (i > 5) {
        printf("Done (cc=%p)\n", cc);
        return 0;
    }
    printf("%d,", i++);
    cc();
    return 1;
}
