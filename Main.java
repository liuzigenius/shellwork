package lx.test.exec;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Main {
	
	private static final String FILE_OUTPUT = "output.txt";

	public static void main(String[] args) {
		
		System.out.println("输入需要输出数字的范围:0 - N");
		Scanner sc = new Scanner(System.in);
		int num = 0;
		try {
			num = Integer.parseInt(sc.nextLine());
		} catch (Exception e) {
			System.out.println("输入有误");
			sc.close();
			System.exit(-1);
		}
		System.out.print("使用回车来输出下一个随机数");
		List<Integer> arr = new ArrayList<Integer>(num + 1);
		for (int i = 0; i <= num; i++) {
			arr.add(i);
		}
		
		new File(FILE_OUTPUT).delete();
		
		while (num >= 0) {
			sc.nextLine();
			int index = (int)(Math.random() * arr.size());
			System.out.print(arr.get(index));
			try (FileWriter writer = new FileWriter(FILE_OUTPUT, true)) {
				writer.write(String.valueOf(arr.get(index)));
				writer.write("\r\n");
			} catch (Exception e) {
				// TODO: handle exception
			}
			arr.remove(index);
			num --;
		}
		
		sc.close();
	}

}
