import sys
import re
import StringIO




def json_token_iterator(data):
	p = r'{|}|:|,|\[|\]|"(\\"|[^"])*"|\d+|true|false|null|\s+'
	r = re.compile(p)
	m = r.match(data)
	while not m is None:
		data = data[m.end():]
		yield m.group(0)
		m = r.match(data)
	print("{0} bytes of input left".format(len(data)))

try:
	content = file(sys.argv[1]).read()
except IndexError:
	print("Please supply a file argument")
	quit(1)
except OSError:
	print("Can't read input file")
	quit(2)

num_indent = 0
write_newline = False
s = StringIO.StringIO()
for t in json_token_iterator(content):
	if write_newline:
		s.write("  " * num_indent)
		write_newline = False
	if t == '{' or t == '[':
		num_indent += 1
		write_newline = True
	elif t == '}' or t == ']':
		num_indent -= 1
		write_newline = True
	elif t == ',':
		write_newline = True
	s.write(t)
	if write_newline:
		s.write("\n")
with open('fmt.json', 'w') as h:
	h.write(s.getvalue())
