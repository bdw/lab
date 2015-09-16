DASM_HEADER := dynasm/dasm_x86.h
OBJDUMP := objdump
all: example.dump

example: example.c dynasm/dasm_x86.h
	cc -g -o example example.c

dynasm/minilua: dynasm/minilua.c
	cc -o dynasm/minilua -lm dynasm/minilua.c

example.c: example.dasc dynasm/minilua dynasm/dynasm.lua dynasm/dasm_x86.lua
	dynasm/minilua dynasm/dynasm.lua -o $@ $< 2> dynasm-log.txt

dynasm/dynasm.lua: 	dynasm/dasm_x86.lua

example.dump: example
	rm example.dump; ./example; $(OBJDUMP) -D -b binary -m i386:x86-64 -M intel example.dump

clean:
	rm -f example example.dump example.c
