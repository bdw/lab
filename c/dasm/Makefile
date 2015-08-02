DASM_HEADER := dynasm/dasm_x86.h
ALL := example
example: example.c dynasm/dasm_x86.h
	cc -g -o example example.c

dynasm/minilua: dynasm/minilua.c
	cc -o dynasm/minilua -lm dynasm/minilua.c

example.c: example.dasc dynasm/minilua dynasm/dynasm.lua dynasm/dasm_x86.lua
	dynasm/minilua dynasm/dynasm.lua -o $@ $<

dynasm/dynasm.lua: 	dynasm/dasm_x86.lua

dump: example
	./example
	objdump -D -b binary -m i386:x86-64 -M intel example.dump

clean:
	rm -f $(ALL) *.c
