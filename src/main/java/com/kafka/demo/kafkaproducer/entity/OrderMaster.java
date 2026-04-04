package com.kafka.demo.kafkaproducer.entity;

import com.kafka.demo.kafkaproducer.enumerator.OrderStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@Table(name = "orders")
@NoArgsConstructor
@AllArgsConstructor
public class OrderMaster {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private int totalQuantity;
    private double totalPrice;
    private Enum<OrderStatus> orderStatus;
    @OneToOne
    private OrderDetails orderDetails;
}
