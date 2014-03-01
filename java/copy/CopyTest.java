import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.FileNotFoundException;

public class CopyTest {
    public static void main(String args[]) {
	FileInputStream input;
	FileOutputStream output;
	try {
	    input = new FileInputStream(args[0]);
	    output = new FileOutputStream(args[0] + ".copy");
	} catch (FileNotFoundException e) {
	    e.printStackTrace();
	    return;
	}
	try {
	    Copy.simple(input, output, 1 << 16);
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
}
