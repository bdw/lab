
public abstract class AbstractQueue<T> {
    private Object getLock = new Object();
    private Object putLock = new Object();
    private int getWaiting = 0;
    private int putWaiting = 0;

    public T get() throws InterruptedException {
	T value = null;
	boolean success = false;
	do { 
	    synchronized (this) {
		if (!isEmpty()) {
		    value = pop();
		    assert value != null;
		    success = true;
		}
	    }
	    if (!success) {
		synchronized (getLock) {
		    getWaiting += 1;
		    getLock.wait(); 
		    // actually, this is a bug; if InterruptedException 
		    // is thrown from wait() then getWaiting will not be 
		    // decreased
		    getWaiting -= 1;
		}
	    }
	} while (!success);
	assert value != null;
	synchronized (putLock) {
	    if (putWaiting > 0) {
		putLock.notify();
	    }
	}
	return value;
    }

    public void put(T value) throws InterruptedException {
	boolean success = false;
	assert value != null;
	do {
	    synchronized (this) {
		if (!isFull()) {
		    push(value);
		    success = true;
		}
	    }
	    if (!success) {
		synchronized(putLock) {
		    putWaiting += 1;
		    putLock.wait();
		    putWaiting -= 1;
		}
	    }
	} while (!success);
	synchronized (getLock) {
	    if (getWaiting > 0) {
		getLock.notify();
	    }
	}
    }

    /* wait until the queue is empty */
    public void join() throws InterruptedException {
	boolean done = false;
	do {
	    synchronized (this) {
		done = isEmpty();
	    }
	    if (!done) {
		// bit confusing to use the putLock
		synchronized (putLock) {
		    putWaiting += 1;
		    putLock.wait();
		    putWaiting -= 1;
		    // re-broadcast the notify (others are waiting)
		    if (putWaiting > 0) {
			putLock.notify();
		    }
		}
	    }
	} while(!done);
    }

    public abstract boolean isEmpty();
    public abstract boolean isFull();
    protected abstract T pop();
    protected abstract void push(T object);
}
