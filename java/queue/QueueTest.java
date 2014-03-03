
public class QueueTest {
    public static void main(String args[]) {
	//	testSimpleQueue();
	//	testPriorityQueue();
	testQueueForConcurrency(false, 7);
	testQueueForConcurrency(true, 9);
	//	testQueueForConcurrency(true);
    }

    private static void testSimpleQueue() {
	try {
	    SimpleQueue<String> queue = new SimpleQueue<String>(3);
	    queue.put("WOW");
	    queue.put("SUCH QUEUE");
	    queue.put("MUCH FIFO");
	    if (queue.isFull()) {
		System.out.println("Queue is full");
	    } else {
		System.out.println("Queue is not full (error)");
	    }
	    for (int i = 0; i < 3; i++) {
		System.out.println(queue.get());
	    }
	    if (queue.isEmpty()) {
		System.out.println("Queue is empty");
	    } else {
		System.out.println("Queue is not empty (error)");
	    }
	} catch (InterruptedException ex) {
	    ex.printStackTrace();
	}
    }

    /* test single threaded usage (not the intended usage */
    private static void testPriorityQueue() {
	String[] keys = new String[]{"WOW", "SUCH PRIORITY", "MUCH HEAP"};
	try {
	    PriorityQueue<String> queue = new PriorityQueue<String>(keys);
	    if (queue.isFull()) {
		System.out.println("Queue is full (OK)");
	    } else {
		System.out.println("Queue is not full (ERROR)");
	    }
	    for (int i = 0; i < keys.length; i++) {
		System.out.println(queue.get());
	    }
	    if (queue.isEmpty()) {
		System.out.println("Queue is empty (OK)");
	    } else {
		System.out.println("Queue is not empty (ERROR)");
	    }
	    queue.put("FOO");
	    queue.put("BAR");
	    queue.put("QUIX");
	    while (!queue.isEmpty()) {
		System.out.println(queue.get());
	    }
	} catch (InterruptedException ex) {
	    ex.printStackTrace();
	}
    }

    private static void testQueueForConcurrency(boolean priorityQueue, 
						int numThreads) {
	String keys[] = new String[]{"A", "B", "C", "D", "E", "F", "G",
				     "H", "I", "J", "K", "L", "M", "N",
				     "O", "P", "Q", "R", "S", "T", "U",
				     "V", "W", "X", "Y", "Z"};
	AbstractQueue<String> queue;
	if (priorityQueue) {
	    String space[] = new String[3];
	    queue = new PriorityQueue<String>(space, false);
	} else {
	    queue = new SimpleQueue<String>(3);
	}
	Producer a = new Producer(queue, keys);
	Producer b = new Producer(queue, keys);
	a.start();
	b.start();
	Thread consumers[] = new Thread[numThreads];
	for (int i = 0; i < numThreads; i++) {
	    consumers[i] = new Consumer(queue, Integer.toString(i));
	    consumers[i].start();
	}
	try {
	    a.join();
	    b.join();
	    // this is not a good way to wait for all producers to end,
	    // by the way - that is not something for a queue to fix
	    // since the queue doesn't know who its clients are!
	    queue.join();
	    // an open question is whether you'd like to signal a 
	    // 'closed' state to clients - this has its drawbacks
	    // because the routines then become much more complex!
	} catch (InterruptedException ex) {
	    System.out.println("INTERRUPT IN JOIN");
	}
	// a stop routine. As the queue has emptied (join()-ed) that 
	// doesn't actually guarantee that the threads have all finished.
	// And when they aren't waiting on something the interruption is
	// lost, so they won't stop. This is basically the argument
	// for sending the 'closed' signal via the channel.
	boolean isAlive;
	do {
	    isAlive = false;
	    for (int i = 0; i < numThreads; i++) {
		if (consumers[i].isAlive()) {
		    consumers[i].interrupt();
		    isAlive = true;
		}
	    }
	} while (isAlive);
    }

    private static class Producer extends Thread {
	private AbstractQueue<String> queue;
	private String[] data;

	public Producer(AbstractQueue<String> queue, String[] data) {
	    this.queue = queue;
	    this.data = data;
	}

	public void run() {
	    try {
		for (int i = 0; i < data.length; i++) {
		    queue.put(data[i]);
		}
		System.out.println("DONE PRODUCING");
	    } catch (InterruptedException ex) {
		System.out.println("PRODUCER INTERRUPTED");
	    }
	}
    }

    private static class Consumer extends Thread {
	private AbstractQueue<String> queue;
	private String name;
	public Consumer(AbstractQueue<String> queue, String name) {
	    this.name = name;
	    this.queue = queue;
	}

	public void run() {
	    try {
		while (true) {
		    String data = queue.get();
		    String msg = String.format("%s: %s", name, data);
		    System.out.println(msg);
		}
	    } catch (InterruptedException ex) {
		System.out.println("DONE CONSUMING");
	    }
	}
    }
}
