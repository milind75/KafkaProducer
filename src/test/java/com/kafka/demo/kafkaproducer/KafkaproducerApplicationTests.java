package com.kafka.demo.kafkaproducer;

import com.kafka.demo.kafkaproducer.service.RabbitMQProducerService;
import org.junit.jupiter.api.Test;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class KafkaproducerApplicationTests {

	@Autowired(required = false)
	private RabbitMQProducerService rabbitMQProducerService;

	@Autowired(required = false)
	private RabbitTemplate rabbitTemplate;

	@DynamicPropertySource
	static void configureProperties(DynamicPropertyRegistry registry) {
		// Override RabbitMQ properties for testing with embedded broker or test container
		// For now, we'll use default test configuration
		registry.add("spring.rabbitmq.host", () -> "localhost");
		registry.add("spring.rabbitmq.port", () -> 5672);
		registry.add("spring.rabbitmq.username", () -> "guest");
		registry.add("spring.rabbitmq.password", () -> "guest");
		registry.add("rabbitmq.exchange.name", () -> "test.exchange");
		registry.add("rabbitmq.routing-key", () -> "test.routing.key");
	}

	@Test
	void contextLoads() {
		// Test that the Spring context loads successfully with RabbitMQ configuration
		assertThat(rabbitTemplate).isNotNull();
	}

	@Test
	void rabbitMQProducerServiceIsAvailable() {
		// Test that RabbitMQProducerService bean is created
		assertThat(rabbitMQProducerService).isNotNull();
	}

	@Test
	void rabbitTemplateIsConfigured() {
		// Test that RabbitTemplate is properly configured
		assertThat(rabbitTemplate).isNotNull();
		assertThat(rabbitTemplate.getConnectionFactory()).isNotNull();
	}
}
