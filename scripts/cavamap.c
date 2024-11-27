#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <locale.h>
#include <errno.h>

typedef unsigned char u8;
typedef unsigned long int u64;
typedef size_t usize;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <bars:uint>\n", argv[0]);
        return 1;
    }

    setlocale(LC_ALL, "");

    char *endptr;
    errno = 0;
    u64 bars = strtoul(argv[1], &endptr, 10);
    if (argv[1] == endptr || errno != 0 || *endptr) {
        fprintf(stderr, "Usage: %s <bars:uint>\n", argv[0]);
        return errno;
    }

    u8 out[3 * bars + 1];
    usize len = 0;
    u64 translated = 0;
    u8 ch;
    while (read(STDIN_FILENO, &ch, 1)) {
        if (ch < 32) {
            out[len++] = ' ';
        } else {
            out[len++] = 226;
            out[len++] = 150;
            out[len++] = 129 + (ch >> 5);
        }

        if (++translated == bars) {
            out[len++] = '\n';
            write(STDOUT_FILENO, out, len);
            len = 0;
            translated = 0;
        }
    }

    return 0;
}
