
.PHONY: all debug clean
all: test_roman test_rot13 test_dlopen

CFLAGS=-g -fPIC

test_dlopen: test_dlopen.c
	$(CC) -g -o $@ $< -ldl

test_rot13: test_rot13.o ./librot13.so
test_roman: test_roman.o ./libroman.so

debug: roman.p6 libroman.so
	perl6-gdb-m roman.p6

librot13.so: rot13.s
	$(CC) -g -shared -o $@ $<

libroman.so: roman.s
	$(CC) -g -shared -o $@ $<

clean:
	rm test_roman test_rot13 test_roman.o test_rot13.o libroman.so librot13.so
