package com.kafka.demo.kafkaproducer.entity;

import com.kafka.demo.kafkaproducer.enumerator.OrderStatus;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class OrderDetails {
    @Id
    private long orderDetailsId;
    private String orderId;
    @OneToOne(cascade = CascadeType.ALL)
    private Product product;
    private String quantity;
    private String price;
}
