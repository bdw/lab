
public abstract class AbstractQueue<T> {
    private Object getCond = new Object();
    private Object putCond = new Object();
    private int getWaiting = 0;
    private int putWaiting = 0;

    public T get() throws InterruptedException {
	T value = null;
	boolean shouldNotify = false;
	boolean getSuccess = false;
	do {
	    synchronized (this) {
		if (!isEmpty()) {
		    value = pop();
		    getSuccess = true;
		    if (putWaiting > 0) {
			shouldNotify = true;
			putWaiting -= 1;
		    }
		} else {
		    getWaiting += 1;
		}
	    }
	    if (!getSuccess) {
		getCond.wait();
	    }
	} while(!getSuccess);
	if (shouldNotify) {
	    putCond.notify();
	}
	return value;
    }

    public void put(T value) throws InterruptedException {
	boolean putSuccess = false;
	boolean shouldNotify = false;
	do {
	    synchronized (this) {
		if (!isFull()) {
		    push(value);
		    putSuccess = true;
		    if (getWaiting > 0) {
			shouldNotify = true;
			getWaiting -= 1;
		    }
		} else {
		    putWaiting += 1;
		}
	    }
	    if (!putSuccess) {
		putCond.wait();
	    }
	} while (!putSuccess);
	if (shouldNotify) {
	    getCond.notify();
	}
    }

    protected abstract boolean isEmpty();
    protected abstract boolean isFull();
    protected abstract T pop();
    protected abstract void push(T object);
}
