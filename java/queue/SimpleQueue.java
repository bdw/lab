
public class SimpleQueue<T> extends AbstractQueue<T> {
    private class Node {
	public T value;
	public Node next;
    }

    private Node head = null, tail = null;
    private Node freeList = null;

    public SimpleQueue(int size) {
	for (int i = 0; i < size; i++) {
	    Node node = new Node();
	    node.next = freeList;
	    freeList = node;
	}
    }

    public SimpleQueue(T[] items) {
	for (int i = 0; i < items.length; i++) {
	    freeList = new Node();
	    push(items[i]);
	}
    }
    
    public boolean isEmpty() {
	return head == null;
    }
    
    public boolean isFull() {
	return freeList == null;
    }
    
    protected void push(T value) {
	// take a node
	Node node = freeList;
	freeList = node.next;
	// initialize
	node.value = value;
	node.next = null;
	// set the head
	if (head == null) {
	    head = node;
	} else {
	    tail.next = node;
	}
	tail = node;
    }
    
    protected T pop() {
	// take the head
	Node node = head;
	T value = node.value;
	// shift the head
	node.value = null;
	head = node.next;
	// push node on free list
	node.next = freeList;
	freeList = node;
	return value;
    }
}
