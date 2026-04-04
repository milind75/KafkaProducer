package com.kafka.demo.kafkaproducer.controller;

import com.kafka.demo.kafkaproducer.service.KafkaProducerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/kafka")
@Tag(name = "Kafka Producer", description = "APIs for sending messages to Kafka topics")
public class KafkaController {

    private final KafkaProducerService producerService;

    public KafkaController(KafkaProducerService producerService) {
        this.producerService = producerService;
    }

    @PostMapping("/send")
    @Operation(
            summary = "Send message to Kafka topic",
            description = "Sends a message to the configured Kafka topic without a specific key"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Message sent successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public String sendMessage(
            @Parameter(description = "Message content to send to Kafka", required = true)
            @RequestParam String message) {
        producerService.sendMessage(message);
        return "Message sent successfully: " + message;
    }

    @PostMapping("/send-with-key")
    @Operation(
            summary = "Send message with key to Kafka topic",
            description = "Sends a message to the configured Kafka topic with a specific partition key"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Message sent successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public String sendMessageWithKey(
            @Parameter(description = "Partition key for the message", required = true)
            @RequestParam String key,
            @Parameter(description = "Message content to send to Kafka", required = true)
            @RequestParam String message) {
        producerService.sendMessage(key, message);
        return "Message sent successfully with key " + key + ": " + message;
    }
}



