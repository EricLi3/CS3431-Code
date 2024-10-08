import java.util.PriorityQueue;

public class test {
    public static void main (String args []) {
        PriorityQueue<Integer> pq = new PriorityQueue<Integer>();

        pq.add(1);
        pq.add(2);

        System.out.println(pq.poll());
        System.out.println(pq.poll());

    }
}
