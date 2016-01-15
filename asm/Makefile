.PHONY: all debug clean
all: libroman.so.1

bar: bar.c libroman.so.1
	$(CC) -g -o $@ $< ./libroman.so.1

debug: roman.p6 libroman.so.1
	perl6-gdb-m roman.p6

libroman.so.1: roman.s
	$(CC) -g -shared -o $@ $<

clean:
	rm libroman.so.1
