
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

    public boolean isEmpty() {
	return head == null;
    }
    
    public boolean isFull() {
	return freeList == null;
    }
    
    protected void push(T value) {
	Node node = freeList;
	freeList = node.next;
	node.value = value;
	if (head == null) {
	    head = node;
	} else {
	    tail.next = node;
	}
	tail = node;
    }
    
    protected T pop() {
	Node node = head;
	T value = node.value;
	node.value = null;
	head = node.next;
	node.next = freeList;
	freeList = node;
	return value;
    }
}
