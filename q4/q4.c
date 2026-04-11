#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*op_func)(int, int);

int main(void)
{
    char op[8];
    char last_op[8] = "";
    int num1, num2;
    void *handle = NULL;
    op_func func = NULL;

    while (scanf("%7s %d %d", op, &num1, &num2) == 3) {

        if (strcmp(op, last_op) != 0) {

            if (handle) {
                dlclose(handle);
                handle = NULL;
                func = NULL;
            }

            char libpath[32];
            snprintf(libpath, sizeof(libpath), "./lib%s.so", op);

            handle = dlopen(libpath, RTLD_LAZY);
            if (!handle) {
                fprintf(stderr, "cannot load %s\n", libpath);
                last_op[0] = '\0';
                continue;
            }

            func = (op_func)dlsym(handle, op);
            if (!func) {
                fprintf(stderr, "cannot find %s\n", op);
                dlclose(handle);
                handle = NULL;
                last_op[0] = '\0';
                continue;
            }

            strncpy(last_op, op, sizeof(last_op) - 1);
            last_op[sizeof(last_op) - 1] = '\0';
        }

        printf("%d\n", func(num1, num2));
    }

    if (handle)
        dlclose(handle);

    return 0;
}