# RabbitMQ Producer Application - Quick Start

## ✅ Your Application is Ready!

Your Spring Boot application has been successfully configured to work with **RabbitMQ** instead of Kafka.

---

## 🚀 Quick Start (Easiest Way)

### Using Docker Compose

This starts both RabbitMQ and your application:

```bash
docker-compose -f docker-compose-ec2.yml up -d
```

That's it! Now access:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)

---

## 📋 Prerequisites

- **Java 17+**
- **Gradle** (included via wrapper)
- **Docker** (for easiest setup)
- OR **RabbitMQ** installed locally

---

## 🏃 Running the Application

### Option 1: Docker Compose (Recommended)

```bash
# Start everything
docker-compose -f docker-compose-ec2.yml up -d

# View logs
docker-compose -f docker-compose-ec2.yml logs -f

# Stop everything
docker-compose -f docker-compose-ec2.yml down
```

### Option 2: Local RabbitMQ + Application

**Step 1: Install RabbitMQ**

**Windows:**
```powershell
choco install rabbitmq
rabbitmq-plugins enable rabbitmq_management
rabbitmq-server
```

**macOS:**
```bash
brew install rabbitmq
brew services start rabbitmq
```

**Linux:**
```bash
sudo apt-get install rabbitmq-server
sudo systemctl start rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
```

**Step 2: Run Application**
```bash
./gradlew bootRun
```

### Option 3: Docker RabbitMQ Only

```bash
# Start RabbitMQ
docker run -d --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3.12-management-alpine

# Run application
./gradlew bootRun
```

---

## 🧪 Testing

### 1. Health Check

```bash
curl http://localhost:8080/actuator/health
```

**Expected:**
```json
{"status":"UP","components":{"rabbit":{"status":"UP"}}}
```

### 2. Send Messages

**Simple message:**
```bash
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=HelloRabbitMQ"
```

**Message with key:**
```bash
curl -X POST "http://localhost:8080/api/rabbitmq/send-with-key?key=user123&message=HelloRabbitMQ"
```

### 3. View Messages in RabbitMQ UI

1. Open: http://localhost:15672
2. Login: `guest` / `guest`
3. Click "Queues" → "orders.queue"
4. Click "Get messages" to see your messages

---

## 📚 API Documentation

### Swagger UI
http://localhost:8080/swagger-ui.html

### Available Endpoints

#### Send Message
```http
POST /api/rabbitmq/send?message={message}
```

#### Send Message with Key
```http
POST /api/rabbitmq/send-with-key?key={key}&message={message}
```

---

## ⚙️ Configuration

### Application Settings (`application.yml`)

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

### Environment Variables

Override settings using environment variables:

```bash
export RABBITMQ_HOST=rabbitmq-server
export RABBITMQ_PORT=5672
export RABBITMQ_USERNAME=myuser
export RABBITMQ_PASSWORD=mypass
export RABBITMQ_EXCHANGE_NAME=my.exchange
export RABBITMQ_QUEUE_NAME=my.queue
export RABBITMQ_ROUTING_KEY=my.routing.key
```

---

## 🐳 Docker Commands

```bash
# Start
docker-compose -f docker-compose-ec2.yml up -d

# Stop
docker-compose -f docker-compose-ec2.yml down

# View logs
docker-compose -f docker-compose-ec2.yml logs -f rabbitmqproducer

# Restart
docker-compose -f docker-compose-ec2.yml restart

# Rebuild
docker-compose -f docker-compose-ec2.yml up -d --build
```

---

## 🔍 Monitoring

### RabbitMQ Management UI

Access: http://localhost:15672

Features:
- View queues, exchanges, bindings
- Monitor message rates
- Manage users and permissions
- View connections
- Performance metrics

### Application Health

```bash
# Overall health
curl http://localhost:8080/actuator/health

# Specific component (RabbitMQ)
curl http://localhost:8080/actuator/health/rabbit
```

---

## 🛠️ Troubleshooting

### Application won't connect to RabbitMQ

**Check if RabbitMQ is running:**
```bash
# Docker
docker ps | grep rabbitmq

# Local
rabbitmqctl status
```

**Verify configuration:**
```yaml
spring:
  rabbitmq:
    host: localhost  # or 'rabbitmq' for Docker
    port: 5672
```

### Can't access Management UI

**Enable management plugin:**
```bash
rabbitmq-plugins enable rabbitmq_management
```

### Messages not appearing in queue

**Check:**
1. Exchange exists: `orders.exchange`
2. Queue exists: `orders.queue`
3. Binding exists: exchange → queue with routing key
4. Application logs for errors

---

## 📁 Project Structure

```
kafkaproducer/
├── src/main/java/com/kafka/demo/kafkaproducer/
│   ├── config/
│   │   ├── Producer.java              # RabbitMQ configuration
│   │   └── OpenApiConfig.java         # Swagger
│   ├── controller/
│   │   └── KafkaController.java       # REST endpoints
│   ├── service/
│   │   └── RabbitMQProducerService.java  # Business logic
│   └── KafkaproducerApplication.java
├── src/main/resources/
│   └── application.yml                # Configuration
├── docker-compose-ec2.yml             # Docker setup
└── build.gradle                       # Dependencies
```

---

## 🔑 Key Features

✅ **RESTful API** for sending messages  
✅ **Swagger UI** for interactive testing  
✅ **Health checks** for monitoring  
✅ **Docker support** for easy deployment  
✅ **Message persistence** with durable queues  
✅ **Retry mechanism** for resilience  
✅ **Management UI** for monitoring  

---

## 📊 RabbitMQ Concepts

### Exchange
Routes messages to queues based on routing rules.
- **Type**: Topic (supports wildcards in routing keys)

### Queue
Stores messages until consumed.
- **Durable**: Survives RabbitMQ restart

### Binding
Links exchange to queue with routing key.
- **Routing Key**: `orders.routing.key`

### Message Flow
```
Producer → Exchange → Binding → Queue → Consumer
```

---

## 🎯 Next Steps

1. ✅ Start RabbitMQ and application
2. ✅ Test endpoints via Swagger UI
3. ✅ Monitor messages in Management UI
4. ⏭️ Deploy to EC2 (see EC2_DEPLOYMENT_GUIDE.md)
5. ⏭️ Add consumer applications
6. ⏭️ Implement message persistence
7. ⏭️ Set up monitoring and alerts

---

## 📚 Documentation

- **Migration Guide**: `KAFKA_TO_RABBITMQ_MIGRATION.md`
- **EC2 Deployment**: `EC2_DEPLOYMENT_GUIDE.md`
- **Docker Guide**: `DOCKER_DEPLOYMENT.md`

---

## 🆘 Common Commands

```bash
# Build
./gradlew clean build -x test

# Run locally
./gradlew bootRun

# Create JAR
./gradlew bootJar

# Run JAR
java -jar build/libs/kafkaproducer-0.0.1-SNAPSHOT.jar

# Test endpoints
curl http://localhost:8080/actuator/health
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=Test"
```

---

## 🎉 You're Ready!

Your RabbitMQ producer application is configured and ready to use!

**Quick start:**
```bash
docker-compose -f docker-compose-ec2.yml up -d
open http://localhost:8080/swagger-ui.html
```

**Happy messaging! 🐰**

