
public class PriorityQueue<T extends Comparable<T>> extends AbstractQueue<T> {
    private T heap[];
    private int cursor = 0;

    public PriorityQueue(T[] items, boolean isFull) {
	heap = items;
	if (isFull) {
	    cursor = items.length;
	    heapify();
	}
    }

    public PriorityQueue(T[] items) {
	this(items, true);
    }

    public boolean isFull() {
	return cursor == heap.length;
    }

    public boolean isEmpty() {
	return cursor == 0;
    }

    protected T pop() {
	T value = heap[0];
	cursor -= 1;
	heap[0] = heap[cursor];
	heap[cursor] = null;
	down(0);
	return value;
    }

    protected void push(T value) {
	heap[cursor] = value;
	up(cursor);
	cursor += 1;
    }

    private void heapify() {
	for (int i = heap.length / 2; i >= 0; i--) {
	    down(i);
	}
    }
    
    private void up(int child) {
	while (child > 0) {
	    int parent = (child-1) / 2;
	    // if parent > child
	    if (heap[parent].compareTo(heap[child]) > 0) {
		swap(parent, child);
		child = parent;
	    } else {
		break;
	    }
	}
    }

    private void down(int parent) {
	while (parent < cursor) {
	    int left = (parent*2)+1;
	    int right = left + 1;
	    int child;
	    if (right < cursor) {
		child = (heap[left].compareTo(heap[right]) > 0 ? right : left);
	    } else if (left < cursor) {
		child = left;
	    } else {
		break;
	    }
	    if (heap[parent].compareTo(heap[child]) > 0) {
		swap(parent, child);
		parent = child;
	    } else {
		break;
	    }
	}
    }

    private void swap(int i, int j) {
	T t = heap[i];
	heap[i] = heap[j];
	heap[j] = t;
    }

}
