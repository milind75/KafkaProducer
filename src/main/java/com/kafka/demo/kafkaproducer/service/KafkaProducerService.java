package com.kafka.demo.kafkaproducer.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;

    @Value("${kafka.topic.name}")
    private String topicName;

    public KafkaProducerService(KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendMessage(String message) {
        kafkaTemplate.send(topicName, message);
        System.out.println("Message sent to topic " + topicName + ": " + message);
    }

    public void sendMessage(String key, String message) {
        kafkaTemplate.send(topicName, key, message);
        System.out.println("Message sent to topic " + topicName + " with key " + key + ": " + message);
    }
}

