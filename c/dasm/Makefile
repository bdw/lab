
example: example.c dynasm/dasm_x86.h
	$(CC) -g example.c

example.c: example.dasc dynasm/dynasm.lua
	luajit dynasm/dynasm.lua -o $@ $<

dynasm/dynasm.lua: 	dynasm/dasm_x86.lua

