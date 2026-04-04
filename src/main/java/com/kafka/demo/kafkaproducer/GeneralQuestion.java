package com.kafka.demo.kafkaproducer;

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.stream.Collectors;

public class GeneralQuestion {
    private final ReentrantLock lock = new ReentrantLock();
    private int count = 0;
    public static void main(String[] args) throws InterruptedException {
//        System.out.println("Hello, World!");
//        GeneralQuestion generalQuestion = new GeneralQuestion();
//        Integer[] arr1 = {1,1,2,2,3,3,4,5,6,6};
//        int[] arr = {1,1,2,2,3,3,4,5,6,6};
//        int[] maxArr = {120,30,4,80,90,3};

//        Arrays.stream(generalQuestion.removeDupliatesFromSortedArray(arr)).forEach(System.out::println);
//        Arrays.stream(generalQuestion.removeDupliatesFromSortedArrayBySet1(arr)).forEach(System.out::println);
//        System.out.println(generalQuestion.removeDuplicates(arr));
//        System.out.println( generalQuestion.getLagestUniqueString("abcabcdabcd"));
//        System.out.println( generalQuestion.findSecondMaxNumber(maxArr));
//        for (int i = 0; i < arr1.length; i++) {
//            Thread t1 = new Thread(generalQuestion::increment);
////            Thread t2 = new Thread(generalQuestion::increment);
//            t1.start();
////            t2.start();
//            t1.join();
////            t2.join();
//            System.out.println(generalQuestion.getCount());
//        }
//            try {
//                System.out.println(generalQuestion.callableFuture());
//            } catch (ExecutionException e) {
//                throw new RuntimeException(e);
//            }
        int[] a = {1,2,3,4,5};
        int [] b = {1,2,2,1,7};
        GeneralQuestion hx = new GeneralQuestion();
        int[] c = hx.findDuplicate(a,b);
        Arrays.stream(c).forEach(System.out::println);
    }
    // Remove Duplicates from Sorted Array
    public Integer[] removeDupliatesFromSortedArray(Integer[] nums) {
        return Arrays.stream(nums).distinct().toArray(Integer[]::new);
    }
    // Remove Duplicates from Sorted Array
    public Integer[] removeDupliatesFromSortedArrayBySet(Integer[] nums) {
        return Arrays.stream(nums).collect(Collectors.toSet()).toArray(Integer[]::new);
    }
    // Remove Duplicates from Sorted Array
    public int[] removeDupliatesFromSortedArrayBySet1(int[] nums) {
        return Arrays.stream(nums).distinct().toArray();
    }
    public int removeDuplicates(int[] nums) {
        int[] newArr = new int[nums.length];
        int j = 1;
        int k = 0;
        for(int i=0;i<nums.length;i++){
            if(nums[i] != nums[j]){
                newArr[k]=nums[i];
                k++;
                j++;
            }
        }
        return k-1;
    }
    public int maxProfit(int[] prices) {
        int max =0;
        for(int i=0; i< prices.length-1;i++){
            for(int j=i; j< prices.length; j++){
                int m = prices[j] - prices[i];
                if( m > max )
                    max =  m;
            }
        }
        return max;
    }
    public int getLagestUniqueString(String str) {
       int left=0;
       Set window  = new HashSet();
       for(int right=0;right<str.length();right++){
           char ch = str.charAt(right);
           while(window.contains(ch)){
               window.remove(str.charAt(left));
               left++;
           }
          window.add(ch);

       }
       return window.size();
    }
    public static int findSecondMaxNumber(int[] nums) {
        int max1=nums[0];
        int k=nums.length-1;
        int max2= nums[k];

//        for(int i=0;i<k;i++){
//            max1=Math.max(max1,nums[i]);
//        }
//        for(int i=0;i<k;i++){
//            if(nums[i] != max1){
//                max2=Math.max(max2,nums[i]);
//            }
//        }
        for(int i=1;i<nums.length;i++ ){
            if(max1<nums[i] && max2<max1){
                max2=max1;
                max1=nums[i];
            } else if(max2<nums[i]){
                max2=nums[i];
            }

        }
        return max2;
    }
    public void increment() {
        lock.lock();
        try {
            count++;
        }finally {
            lock.unlock();
        }
    }
    public int getCount() {
        return count;
    }
    public int callableFuture() throws ExecutionException, InterruptedException {
        ExecutorService executor = Executors.newFixedThreadPool(10);
        Callable<Integer> task = () -> {
            Thread.sleep(1000);
            return 10 * 10;
        };
        Future<Integer> future = executor.submit(task);
        int result = future.get();
        executor.shutdown();
        return result;
    }
    public int[] findDuplicate(int[] a, int[] b) {
        // Find common elements between two arrays
        Map<Integer, Integer> countMap = new HashMap<>();
        List<Integer> result = new ArrayList<>();
        
        // Count occurrences in array a
        for (int num : a) {
            countMap.put(num, countMap.getOrDefault(num, 0) + 1);
        }
        
        // Check if elements from array b exist in array a
        for (int num : b) {
            if (countMap.containsKey(num) && countMap.get(num) > 0) {
                result.add(num);
                countMap.put(num, countMap.get(num) - 1);
            }
        }
        
        // Convert List to array
        return result.stream().mapToInt(Integer::intValue).toArray();
    }

}

