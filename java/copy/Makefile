


test: CopyTest.class random.bytes
	java CopyTest random.bytes
	sh checksum.sh random.bytes random.bytes.copy

CopyTest.java: Copy.class

%.class: %.java
	javac $<

clean:
	rm -f random.bytes *.class

random.bytes:
	dd if=/dev/urandom of=random.bytes bs=16k count=1024
