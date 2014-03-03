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


    private static class Reader extends Thread {
	private InputStream input;
	private byte[] reserve;
	
	public boolean ready;
	public byte[] buffer;
	public int count;
	public IOException exception;

	public Reader(InputStream input, int bufSize) {
	    this.input = input;
	    this.buffer = new byte[bufSize];
	    this.reserve = new byte[bufSize];
	    this.ready = false;
	}

	public void run() {
	    try {
		byte[] current = buffer;
		for (count = input.read(current); count >= 0; 
		     count = input.read(current)) {
		    synchronized (this) {
			ready = true;
			buffer = current;
			notifyAll();
			wait();
			current = reserve;
			reserve = buffer;
		    }
		}
	    } catch (InterruptedException e) {
	    } catch (IOException e) {
		exception = e;
	    }
	    synchronized (this) {
		notifyAll();
		// in case you're waiting
	    }

	}
    }

    private static class Writer extends Thread {
	private OutputStream output;
	private Reader reader;
	public IOException exception;

	public Writer(OutputStream output, Reader reader) {
	    this.output = output;
	    this.reader = reader;
	}
	
	public void run() {
	    byte[] buffer;
	    int count;
	    while (reader.isAlive()) {
		synchronized(reader) {
		    // pull data from the reader
		    while (reader.isAlive() && !reader.ready) {
			try {
			    reader.wait();
			} catch (InterruptedException e) {
			    return;
			}
		    }
		    if (!reader.isAlive())
			break;
		    buffer = reader.buffer;
		    count = reader.count;
		    reader.ready = false;
		    reader.notify();
		}
		try {
		    output.write(buffer, 0, count);
		} catch (IOException e) {
		    exception = e;
		    return;
		}
	    }
	}
    }

    public static void threaded(InputStream in, OutputStream out, int bufSize)
	throws IOException, InterruptedException {
	Reader reader = new Reader(in, bufSize);
	Writer writer = new Writer(out, reader);
	reader.start();
	writer.start();
	writer.join();
	while (reader.isAlive()) {
	    reader.interrupt();
	}
	if (reader.exception != null) 
	    throw reader.exception;
	if (writer.exception != null)
	    throw writer.exception;
    }
}
