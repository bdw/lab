#include <stdio.h>
#include <stdlib.h>

void *walk_stack_posix(void *low, void *high);

void foo(void);
int main(int argc, char **argv);

void bar (void) {
    void *foo_ptr = walk_stack_posix(foo, foo + 64);
    void *main_ptr = walk_stack_posix(main, main + 64);
    void (*my_foo)(void) = foo_ptr;
    void (*my_main)(void) = main_ptr;
    fprintf(stderr, "Our return address is = %lX\n", (uintptr_t)foo_ptr);
    my_foo();
    fputs("back from foo\n", stderr);
    /* we can't return because foo returned for us */
    my_main();
}

void foo (void) {
    fputs("foo before bar\n", stderr);
    bar();
    fputs("foo after bar\n", stderr);
    return;
}



int main(int argc, char **argv) {
    fputs("main\n", stderr);
    foo();
    fputs("exti\n", stderr);
    _Exit(0);
}
