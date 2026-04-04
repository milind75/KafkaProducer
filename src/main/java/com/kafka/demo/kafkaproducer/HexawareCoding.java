package com.kafka.demo.kafkaproducer;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class HexawareCoding {

    public static void main(String[] args) {
        int[] a = {1,2,3,4,5};
        int [] b = {1,2,2,1,7};
        HexawareCoding hx = new HexawareCoding();
        int[] c = hx.findDuplicate(a,b);
        Arrays.stream(c).forEach(System.out::println);
    }
    public int[] findDuplicate(int[] a, int[] b) {
        Map<Integer, Integer> map = new HashMap<>();
        int[] newArray = new int[a.length];
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < b.length; j++) {
                if ( map.containsKey(b[j] )) {
                    map.put(a[i], map.get(a[i]) + 1);
                } else {
                    map.put(a[i], 0);
                }
            }
        }
        for (Integer key : map.keySet()) {
            if (map.get(key) > 0) {
                newArray[key] = key;
            }
        }
        return newArray;
    }
}
