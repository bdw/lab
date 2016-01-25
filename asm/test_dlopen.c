#include <stdio.h>
#include <dlfcn.h>

int main(int argc, char **argv) {
    void * handle, *symbol;
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <library> <symbol>\n", argv[0]);
        return 1;
    }
    handle = dlopen(argv[1], RTLD_LAZY);
    if (handle == NULL) {
        fprintf(stderr, "Error: %s\n", dlerror());
        return 1;
    }
    symbol = dlsym(handle, argv[2]);
    if (symbol == NULL) {
        fprintf(stderr, "Error: %s\n", dlerror());
        return 1;
    } else {
        fprintf(stderr, "Succes: %p\n", symbol);
    }
    dlclose(handle);
    return 0;
}
