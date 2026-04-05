# 🔄 Migration from Kafka to RabbitMQ - Complete Guide

## ✅ Migration Summary

Your application has been successfully migrated from **Apache Kafka** to **RabbitMQ**!

### What Changed:

| Component | Kafka (Before) | RabbitMQ (After) |
|-----------|----------------|------------------|
| **Messaging System** | Apache Kafka | RabbitMQ |
| **Dependency** | `spring-boot-starter-kafka` | `spring-boot-starter-amqp` |
| **Configuration** | Bootstrap servers, topics | Host, port, exchanges, queues |
| **Endpoint** | `/api/kafka/*` | `/api/rabbitmq/*` |
| **Port** | 9092 | 5672 |
| **Management UI** | - | 15672 (RabbitMQ Management) |
| **Service** | KafkaProducerService | RabbitMQProducerService |

---

## 📋 Changes Made

### 1. Dependencies (`build.gradle`)

**Before (Kafka):**
```gradle
implementation 'org.springframework.boot:spring-boot-starter-kafka'
testImplementation 'org.springframework.boot:spring-boot-starter-kafka-test'
```

**After (RabbitMQ):**
```gradle
implementation 'org.springframework.boot:spring-boot-starter-amqp'
testImplementation 'org.springframework.amqp:spring-rabbit-test'
```

### 2. Configuration (`application.yml`)

**Before (Kafka):**
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    
kafka:
  topic:
    name: ordersTopic
```

**After (RabbitMQ):**
```yaml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
    
rabbitmq:
  exchange:
    name: orders.exchange
  queue:
    name: orders.queue
  routing-key: orders.routing.key
```

### 3. Service Layer

**Before:** `KafkaProducerService.java`
```java
@Service
public class KafkaProducerService {
    private final KafkaTemplate<String, String> kafkaTemplate;
    
    public void sendMessage(String message) {
        kafkaTemplate.send(topicName, message);
    }
}
```

**After:** `RabbitMQProducerService.java`
```java
@Service
public class RabbitMQProducerService {
    private final RabbitTemplate rabbitTemplate;
    
    public void sendMessage(String message) {
        rabbitTemplate.convertAndSend(exchangeName, routingKey, message);
    }
}
```

### 4. Configuration Class (`Producer.java`)

**Before (Kafka):**
```java
@Configuration
public class Producer {
    // Auto-configured by Spring Boot
}
```

**After (RabbitMQ):**
```java
@Configuration
public class Producer {
    @Bean
    public Queue queue() { ... }
    
    @Bean
    public TopicExchange exchange() { ... }
    
    @Bean
    public Binding binding() { ... }
}
```

### 5. REST API Endpoints

**Before:**
- `POST /api/kafka/send`
- `POST /api/kafka/send-with-key`

**After:**
- `POST /api/rabbitmq/send`
- `POST /api/rabbitmq/send-with-key`

### 6. Docker Compose

**Before (Kafka + Zookeeper):**
```yaml
services:
  zookeeper: ...
  kafka: ...
  kafkaproducer: ...
```

**After (RabbitMQ):**
```yaml
services:
  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"
  rabbitmqproducer: ...
```

---

## 🚀 How to Run with RabbitMQ

### Option 1: Using Docker Compose (Recommended)

This will start both RabbitMQ and your application:

```bash
docker-compose -f docker-compose-ec2.yml up -d
```

Access:
- **Application**: http://localhost:8080/swagger-ui.html
- **RabbitMQ Management UI**: http://localhost:15672 (guest/guest)

### Option 2: Local RabbitMQ + Application

**Step 1: Install and run RabbitMQ**

**Windows (using Chocolatey):**
```powershell
choco install rabbitmq
rabbitmq-plugins enable rabbitmq_management
rabbitmq-server
```

**macOS (using Homebrew):**
```bash
brew install rabbitmq
brew services start rabbitmq
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install rabbitmq-server
sudo systemctl start rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
```

**Step 2: Run the application**
```bash
./gradlew bootRun
```

### Option 3: Using Docker for RabbitMQ only

```bash
# Start RabbitMQ
docker run -d --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3.12-management-alpine

# Run application locally
./gradlew bootRun
```

---

## 🧪 Testing the Migration

### 1. Check Application Health

```bash
curl http://localhost:8080/actuator/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "components": {
    "rabbit": {
      "status": "UP"
    }
  }
}
```

### 2. Send a Test Message

```bash
# Send simple message
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=HelloRabbitMQ"

# Send message with key
curl -X POST "http://localhost:8080/api/rabbitmq/send-with-key?key=test123&message=HelloRabbitMQ"
```

### 3. Verify in RabbitMQ Management UI

1. Open: http://localhost:15672
2. Login: guest / guest
3. Go to "Queues" tab
4. Click on "orders.queue"
5. Scroll down to "Get messages" and click "Get Message(s)"
6. You should see your test messages

### 4. Using Swagger UI

1. Open: http://localhost:8080/swagger-ui.html
2. Expand "RabbitMQ Producer"
3. Try the endpoints interactively

---

## 📊 Key Differences: Kafka vs RabbitMQ

| Feature | Kafka | RabbitMQ |
|---------|-------|----------|
| **Architecture** | Distributed log | Message broker |
| **Message Model** | Publish-Subscribe | Exchange-Queue-Binding |
| **Message Ordering** | Per partition | Per queue |
| **Message Persistence** | Always persisted | Optional (durable queues) |
| **Consumer Groups** | Native support | Competing consumers |
| **Message TTL** | Via retention | Native support |
| **Management UI** | Third-party tools | Built-in |
| **Best For** | Event streaming, logs | Task queues, RPC |

---

## 🔧 Configuration Options

### RabbitMQ Exchange Types

You can change the exchange type in `Producer.java`:

```java
// Topic Exchange (current - supports wildcards)
@Bean
public TopicExchange exchange() {
    return new TopicExchange(exchangeName);
}

// Direct Exchange (exact routing key match)
@Bean
public DirectExchange exchange() {
    return new DirectExchange(exchangeName);
}

// Fanout Exchange (broadcast to all queues)
@Bean
public FanoutExchange exchange() {
    return new FanoutExchange(exchangeName);
}
```

### Message Priority

Enable priority queue:

```java
@Bean
public Queue queue() {
    Map<String, Object> args = new HashMap<>();
    args.put("x-max-priority", 10);
    return new Queue(queueName, true, false, false, args);
}
```

### Message TTL (Time To Live)

```java
rabbitTemplate.convertAndSend(exchangeName, routingKey, message, m -> {
    m.getMessageProperties().setExpiration("60000"); // 60 seconds
    return m;
});
```

---

## 🛠️ Troubleshooting

### Issue: Connection Refused

**Solution:**
```bash
# Check if RabbitMQ is running
# Windows
rabbitmqctl status

# Linux/Mac
sudo systemctl status rabbitmq-server

# Docker
docker ps | grep rabbitmq
```

### Issue: Authentication Failed

**Solution:** Update credentials in `application.yml`:
```yaml
spring:
  rabbitmq:
    username: your-username
    password: your-password
```

### Issue: Queue/Exchange Not Found

**Solution:** The application auto-creates queues and exchanges on startup. If issues persist:
```bash
# Manually create (RabbitMQ Management UI or CLI)
rabbitmqadmin declare exchange name=orders.exchange type=topic
rabbitmqadmin declare queue name=orders.queue durable=true
rabbitmqadmin declare binding source=orders.exchange destination=orders.queue routing_key=orders.routing.key
```

---

## 📦 EC2 Deployment with RabbitMQ

### Update `deploy-to-ec2.sh`

Add RabbitMQ installation:

```bash
# Install RabbitMQ on EC2
sudo yum install -y https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.0/rabbitmq-server-3.12.0-1.el8.noarch.rpm
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
```

### Update Security Group

Allow these ports:
- **5672**: AMQP (RabbitMQ messaging)
- **15672**: Management UI
- **8080**: Application API

---

## 🎯 API Changes Summary

### Old Kafka Endpoints:
```
POST /api/kafka/send?message=hello
POST /api/kafka/send-with-key?key=123&message=hello
```

### New RabbitMQ Endpoints:
```
POST /api/rabbitmq/send?message=hello
POST /api/rabbitmq/send-with-key?key=123&message=hello
```

**Note:** Update any client applications to use the new endpoints!

---

## ✅ Migration Checklist

- [x] Dependencies updated (Kafka → RabbitMQ)
- [x] Configuration files updated
- [x] Service layer migrated
- [x] Producer configuration created
- [x] Controller endpoints updated
- [x] Docker Compose updated
- [x] Application builds successfully
- [ ] RabbitMQ installed and running
- [ ] Application tested locally
- [ ] Client applications updated to use new endpoints
- [ ] Monitoring and alerts updated
- [ ] Documentation updated

---

## 📚 Additional Resources

- **RabbitMQ Documentation**: https://www.rabbitmq.com/documentation.html
- **Spring AMQP**: https://spring.io/projects/spring-amqp
- **RabbitMQ Tutorials**: https://www.rabbitmq.com/getstarted.html
- **Management Plugin**: https://www.rabbitmq.com/management.html

---

## 🎉 Migration Complete!

Your application has been successfully migrated from Kafka to RabbitMQ. The main concepts remain the same (producers, consumers, messaging), but the implementation now uses RabbitMQ's exchange-queue-binding model instead of Kafka's topics and partitions.

### Quick Start Commands:

```bash
# Start RabbitMQ and application
docker-compose -f docker-compose-ec2.yml up -d

# View logs
docker-compose -f docker-compose-ec2.yml logs -f

# Send test message
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=Test"

# Access management UI
open http://localhost:15672
```

**Your RabbitMQ producer is ready to use! 🐰**

