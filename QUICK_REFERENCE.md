# RabbitMQ Producer - Quick Reference Card

## 🚀 Start Application

```bash
docker-compose -f docker-compose-ec2.yml up -d
```

## 🌐 Access URLs

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **RabbitMQ UI**: http://localhost:15672 (guest/guest)
- **Health**: http://localhost:8080/actuator/health

## 📡 API Endpoints

```bash
# Send message
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=Hello"

# Send with key
curl -X POST "http://localhost:8080/api/rabbitmq/send-with-key?key=user1&message=Hello"
```

## 🐳 Docker Commands

```bash
# Start
docker-compose -f docker-compose-ec2.yml up -d

# Stop
docker-compose -f docker-compose-ec2.yml down

# Logs
docker-compose -f docker-compose-ec2.yml logs -f

# Restart
docker-compose -f docker-compose-ec2.yml restart

# Rebuild
docker-compose -f docker-compose-ec2.yml up -d --build
```

## 🔧 Configuration

### RabbitMQ Connection
- **Host**: localhost
- **Port**: 5672
- **User**: guest
- **Pass**: guest

### Queue/Exchange
- **Exchange**: orders.exchange (topic)
- **Queue**: orders.queue
- **Routing Key**: orders.routing.key

## 📊 Key Differences: Kafka vs RabbitMQ

| Kafka | RabbitMQ |
|-------|----------|
| Port 9092 | Port 5672 |
| No UI | UI on 15672 |
| Topics | Exchanges/Queues |
| Needs Zookeeper | Standalone |

## 📚 Documentation

- `RABBITMQ_QUICK_START.md` - Quick start
- `KAFKA_TO_RABBITMQ_MIGRATION.md` - Migration details
- `MIGRATION_COMPLETE.md` - Summary

## ✅ Checklist

- [ ] RabbitMQ running
- [ ] Application running  
- [ ] Test message sent
- [ ] Message visible in UI

## 🆘 Troubleshooting

```bash
# Check services
docker ps

# View logs
docker logs rabbitmq
docker logs rabbitmqproducer

# Restart
docker-compose -f docker-compose-ec2.yml restart
```

---

**Quick Start**: `docker-compose -f docker-compose-ec2.yml up -d`

