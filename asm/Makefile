OBJECTS:= test_roman test_rot13 test_dlopen test_fib test_cont

.PHONY: all debug clean
all: $(OBJECTS)

test_dlopen: test_dlopen.c
	$(CC) -g -o $@ $< -ldl

test_rot13: test_rot13.o ./librot13.so
	$(CC) -o $@ $< ./librot13.so

test_roman: test_roman.o ./libroman.so
	$(CC) -o $@ $< ./libroman.so

test_fib: test_fib.c fib.s
	$(CC) -g -o $@ test_fib.c fib.s

test_cont: test_cont.c cont.s
	$(CC) -g -o $@ test_cont.c cont.s

debug: roman.p6 libroman.so
	perl6-gdb-m roman.p6

librot13.so: rot13.s
	$(CC) -g -shared -o $@ $<

libroman.so: roman.s
	$(CC) -g -shared -o $@ $<


test_stack_walk: stack_walk.s test_stack_walk.c
	$(CC) -g -fno-omit-frame-pointer -o $@ stack_walk.s test_stack_walk.c

clean:
	rm -f $(OBJECTS) *.so *.o
