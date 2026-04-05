package com.kafka.demo.kafkaproducer.service;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class RabbitMQProducerService {

    private final RabbitTemplate rabbitTemplate;

    @Value("${rabbitmq.exchange.name}")
    private String exchangeName;

    @Value("${rabbitmq.routing-key}")
    private String routingKey;

    public RabbitMQProducerService(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void sendMessage(String message) {
        rabbitTemplate.convertAndSend(exchangeName, routingKey, message);
        System.out.println("Message sent to RabbitMQ exchange " + exchangeName + " with routing key " + routingKey + ": " + message);
    }

    public void sendMessage(String key, String message) {
        // In RabbitMQ, we can use message properties to add custom headers
        rabbitTemplate.convertAndSend(exchangeName, routingKey, message, m -> {
            m.getMessageProperties().setHeader("key", key);
            return m;
        });
        System.out.println("Message sent to RabbitMQ exchange " + exchangeName + " with key " + key + ": " + message);
    }
}

