
example: example.c
	$(CC) -g example.c

%.c: %.dasc
	lua dynasm/dynasm.lua -o $@ $<


