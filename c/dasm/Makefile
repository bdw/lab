
example: example.c
	$(CC) example.c

%.c: %.dasc
	lua dynasm/dynasm.lua -o $@ $<


