import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Copy {
    
    public static void simple(InputStream in, OutputStream out, int bufSize) 
	throws IOException {
	byte[] buffer = new byte[bufSize];
	for (int c = in.read(buffer); c >= 0; c = in.read(buffer)) {
	    out.write(buffer, 0, c);
	}
    }


    /* Threaded copying is much more complex because the reads and
     * writes need to be coordinated. I have chosen to 'push' values
     * from the reader to the writer because I believe it to be
     * simpler. */
    private static class Reader extends Thread {
	private InputStream input;
	private byte[] buffer, reserve;
	private Writer writer;
	private IOException exception;

	public Reader(InputStream input, Writer writer, int bufSize) {
	    this.input = input;
	    this.writer = writer;
	    this.buffer = new byte[bufSize];
	    this.reserve = new byte[bufSize];
	}

	public void run() {
	    try {
		byte[] current = buffer;
		int total = 0;
		for (int count = input.read(current); count >= 0;
		     count = input.read(current)) {
		    if(!writer.push(current, count)) {
			break;
		    }
		    total += count;
		    // swap buffers
		    buffer = reserve;
		    reserve = current;
		    current = buffer;
		}
		System.out.printf("Total bytes written: %d\n", total);
	    } catch (IOException x) {
		exception = x;
	    } finally {
		writer.close();
		System.out.println("Done with reader");
	    }
	}
    }

    private static class Writer extends Thread {
	private OutputStream output;
	private byte[] data;
	private int count;
	private boolean isOpen, hasData;
	public IOException exception;

	public Writer(OutputStream output) {
	    this.output = output;
	    this.hasData = false;
	    this.isOpen = true;
	}

	public synchronized void run() {
	    while (isOpen) {
		try {
		    System.out.println("Pulling");
		    while (isOpen && !hasData) {
			wait();
		    }
		} catch (InterruptedException x) {
		    isOpen = false;
		    notifyAll();
		}
		if (!isOpen)
		    break;
		try {
		    output.write(data, 0, count);
		} catch (IOException x) {
		    isOpen = false;
		    exception = x;
		}
		hasData = false;
		notify();
	    }
	}

	public synchronized boolean push(byte[] data, int count) {
	    try {
		while (isOpen && hasData) {
		    wait();
		}
	    } catch (InterruptedException x) {
		return false;
	    }
	    if (!isOpen) {
		return false;
	    }
	    this.data = data;
	    this.count = count;
	    hasData = true;
	    notify();
	    return true;
	}

	public synchronized void close() {
	    System.out.println("Closing");
	    isOpen = false;
	    notifyAll();
	}
    }


    public static void threaded(InputStream in, OutputStream out, int bufSize) 
	throws IOException {
	Writer writer = new Writer(out);
	Reader reader = new Reader(in, writer, bufSize);
	reader.start();
	writer.start();
	System.out.println("Started both threads");
	try {
	    writer.join();
	    reader.join();
	} catch (InterruptedException x) {
	    return;
	}
	if (reader.exception != null) {
	    throw reader.exception;
	} else if (writer.exception != null) {
	    throw writer.exception;
	}
    }
}
