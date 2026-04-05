package com.kafka.demo.kafkaproducer.controller;

import com.kafka.demo.kafkaproducer.service.RabbitMQProducerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rabbitmq")
@Tag(name = "RabbitMQ Producer", description = "APIs for sending messages to RabbitMQ queues")
public class KafkaController {

    private final RabbitMQProducerService producerService;

    public KafkaController(RabbitMQProducerService producerService) {
        this.producerService = producerService;
    }

    @PostMapping("/send")
    @Operation(
            summary = "Send message to RabbitMQ queue",
            description = "Sends a message to the configured RabbitMQ exchange and queue"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Message sent successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public String sendMessage(
            @Parameter(description = "Message content to send to RabbitMQ", required = true)
            @RequestParam String message) {
        producerService.sendMessage(message);
        return "Message sent successfully to RabbitMQ: " + message;
    }

    @PostMapping("/send-with-key")
    @Operation(
            summary = "Send message with key to RabbitMQ queue",
            description = "Sends a message to the configured RabbitMQ exchange with a custom header key"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Message sent successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public String sendMessageWithKey(
            @Parameter(description = "Custom key header for the message", required = true)
            @RequestParam String key,
            @Parameter(description = "Message content to send to RabbitMQ", required = true)
            @RequestParam String message) {
        producerService.sendMessage(key, message);
        return "Message sent successfully to RabbitMQ with key " + key + ": " + message;
    }
}



