
test: QueueTest.class
	java -ea QueueTest

%.class: %.java
	javac $<

QueueTest.java: PriorityQueue.class SimpleQueue.class AbstractQueue.class  

clean: 
	rm -f *.class
