
public class QueueTest {
    public static void main(String args[]) {
	//	testSimpleQueue();
	//	testPriorityQueue();
	testQueueForConcurrency(true, 5);
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
	Producer prod = new Producer(queue, keys);
	prod.start();
	Thread consumers[] = new Thread[numThreads];
	for (int i = 0; i < numThreads; i++) {
	    consumers[i] = new Consumer(queue, Integer.toString(i));
	    consumers[i].start();
	}
	try {
	    prod.join();
	} catch (InterruptedException ex) {
	    System.out.println("INTERRUPT IN JOIN");
	}
	try {
	    synchronized (queue) {
		while (!queue.isEmpty()) {
		    queue.wait();
		}
	    } 
	} catch (InterruptedException ex) {
	    System.out.println("INTERUPT IN WAIT");
	}
	for (int i = 0; i < numThreads; i++) {
	    consumers[i].interrupt();
	}
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
