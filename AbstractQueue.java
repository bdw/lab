
public abstract class AbstractQueue<T> {

    public synchronized T get() throws InterruptedException {
	T value = null;
	while(isEmpty()) {
	    wait();
	}
	value = pop();
	notifyAll();
	return value;
    }

    public synchronized void put(T value) throws InterruptedException {
	while (isFull()) {
	    wait();
	}
	push(value);
	notifyAll();
    }

    protected abstract boolean isEmpty();
    protected abstract boolean isFull();
    protected abstract T pop();
    protected abstract void push(T object);
}
