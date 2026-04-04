package com.kafka.demo.kafkaproducer.enumerator;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;

public enum OrderStatus {
    RECEIVED("Received"),
    PENDING("Pending"),
    PROCESSING("Processing"),
    COMPLETED("Completed"),
    CANCELLED("Cancelled");
    @Getter
    private String value;
    OrderStatus(String value) {
        this.value = value;
    }
}