# Docker Deployment Guide - EC2

This guide explains how to deploy your Kafka Producer application using Docker on EC2.

## Prerequisites

- EC2 instance running (Amazon Linux 2023 or Ubuntu)
- Docker and Docker Compose installed on EC2
- Application code transferred to EC2

---

## Step 1: Install Docker on EC2

### For Amazon Linux 2023 / Amazon Linux 2

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again for group changes to take effect
exit
```

### For Ubuntu

```bash
# Update system
sudo apt update
sudo apt install -y docker.io docker-compose

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -a -G docker ubuntu

# Logout and login again
exit
```

---

## Step 2: Transfer Application to EC2

### Option A: Using Git (Recommended)

```bash
# On EC2
git clone https://your-repo/kafkaproducer.git
cd kafkaproducer
```

### Option B: Using SCP

```powershell
# On your local machine
cd C:\Users\milin\IdeaProjects\kafkaproducer

# Create a zip file
Compress-Archive -Path * -DestinationPath kafkaproducer.zip

# Transfer to EC2
scp -i your-key.pem kafkaproducer.zip ec2-user@your-ec2-ip:~

# On EC2
ssh -i your-key.pem ec2-user@your-ec2-ip
unzip kafkaproducer.zip
cd kafkaproducer
```

---

## Step 3: Build and Run with Docker Compose

### Option 1: Full Stack (Kafka + Application)

```bash
# Build and start all services (Zookeeper, Kafka, Application)
docker-compose -f docker-compose-ec2.yml up -d

# View logs
docker-compose -f docker-compose-ec2.yml logs -f

# Check status
docker-compose -f docker-compose-ec2.yml ps
```

This will start:
- Zookeeper on port 2181
- Kafka on port 9092
- Your application on port 8080

### Option 2: Application Only (External Kafka)

If you have Kafka running elsewhere, create `docker-compose-app-only.yml`:

```yaml
version: '3.8'

services:
  kafkaproducer:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: kafkaproducer
    ports:
      - "8080:8080"
    environment:
      KAFKA_BOOTSTRAP_SERVERS: your-kafka-server:9092
      KAFKA_TOPIC_NAME: ordersTopic
    volumes:
      - ./logs:/opt/kafkaproducer/logs
    restart: unless-stopped
```

Then run:
```bash
docker-compose -f docker-compose-app-only.yml up -d
```

---

## Step 4: Verify Deployment

```bash
# Check running containers
docker ps

# Check application logs
docker logs -f kafkaproducer

# Test health endpoint
curl http://localhost:8080/actuator/health

# Access Swagger UI
curl http://localhost:8080/swagger-ui.html
```

From your browser:
```
http://your-ec2-public-ip:8080/swagger-ui.html
```

---

## Step 5: Test Kafka Integration

```bash
# Enter Kafka container
docker exec -it kafka bash

# Create topic
kafka-topics --create --topic ordersTopic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# List topics
kafka-topics --list --bootstrap-server localhost:9092

# Consume messages
kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic ordersTopic --from-beginning
```

In another terminal, send a test message:
```bash
curl -X POST "http://localhost:8080/api/kafka/send?message=TestFromDocker"
```

---

## Management Commands

### Start/Stop Services

```bash
# Start all services
docker-compose -f docker-compose-ec2.yml start

# Stop all services
docker-compose -f docker-compose-ec2.yml stop

# Restart all services
docker-compose -f docker-compose-ec2.yml restart

# Stop and remove containers
docker-compose -f docker-compose-ec2.yml down

# Stop and remove containers + volumes
docker-compose -f docker-compose-ec2.yml down -v
```

### View Logs

```bash
# All services
docker-compose -f docker-compose-ec2.yml logs -f

# Specific service
docker-compose -f docker-compose-ec2.yml logs -f kafkaproducer
docker-compose -f docker-compose-ec2.yml logs -f kafka
```

### Execute Commands in Container

```bash
# Application container
docker exec -it kafkaproducer sh

# Kafka container
docker exec -it kafka bash
```

---

## Update Application

### Method 1: Rebuild Container

```bash
# Pull latest code (if using Git)
git pull

# Rebuild and restart
docker-compose -f docker-compose-ec2.yml up -d --build

# Or rebuild specific service
docker-compose -f docker-compose-ec2.yml up -d --build kafkaproducer
```

### Method 2: Manual Update

```bash
# Stop application
docker-compose -f docker-compose-ec2.yml stop kafkaproducer

# Remove container
docker-compose -f docker-compose-ec2.yml rm -f kafkaproducer

# Build new image
docker build -t kafkaproducer:latest .

# Start container
docker-compose -f docker-compose-ec2.yml up -d kafkaproducer
```

---

## Production Considerations

### 1. Use Environment Variables

Create `.env` file:
```env
KAFKA_BOOTSTRAP_SERVERS=kafka:29092
KAFKA_TOPIC_NAME=ordersTopic
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod
```

Update `docker-compose-ec2.yml`:
```yaml
services:
  kafkaproducer:
    env_file:
      - .env
```

### 2. Persist Data Volumes

```yaml
volumes:
  kafka-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/kafka-data
```

### 3. Resource Limits

Add to `docker-compose-ec2.yml`:
```yaml
services:
  kafkaproducer:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G
```

### 4. Health Checks

Already included in Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1
```

### 5. Logging

Configure log rotation:
```bash
# Create Docker daemon config
sudo nano /etc/docker/daemon.json
```

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

```bash
# Restart Docker
sudo systemctl restart docker
```

---

## Monitoring

### Container Stats

```bash
# Real-time stats
docker stats

# Specific container
docker stats kafkaproducer
```

### Disk Usage

```bash
# Check Docker disk usage
docker system df

# Detailed view
docker system df -v

# Clean up unused resources
docker system prune -a
```

---

## Troubleshooting

### Application Won't Start

```bash
# Check logs
docker logs kafkaproducer

# Check if port is available
sudo netstat -tlnp | grep 8080

# Check container status
docker inspect kafkaproducer
```

### Can't Connect to Kafka

```bash
# Check if Kafka is running
docker ps | grep kafka

# Check Kafka logs
docker logs kafka

# Test Kafka connectivity from app container
docker exec -it kafkaproducer sh
nc -zv kafka 29092
```

### Out of Memory

```bash
# Check container memory usage
docker stats kafkaproducer

# Increase memory limit in docker-compose-ec2.yml
# Or adjust JAVA_OPTS in Dockerfile
```

---

## Backup & Restore

### Backup Volumes

```bash
# Backup Kafka data
docker run --rm -v kafka-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/kafka-backup.tar.gz /data

# Backup application logs
docker run --rm -v app-logs:/logs -v $(pwd):/backup \
  alpine tar czf /backup/logs-backup.tar.gz /logs
```

### Restore Volumes

```bash
# Restore Kafka data
docker run --rm -v kafka-data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/kafka-backup.tar.gz -C /
```

---

## Security Best Practices

1. **Don't expose Kafka ports publicly**
   - Only expose 8080 for the application
   - Keep 9092 internal to Docker network

2. **Use secrets for sensitive data**
   ```bash
   docker secret create db_password ./db_password.txt
   ```

3. **Run containers as non-root**
   - Already configured in Dockerfile

4. **Keep images updated**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Scan images for vulnerabilities**
   ```bash
   docker scan kafkaproducer:latest
   ```

---

## Quick Reference

```bash
# Build and start
docker-compose -f docker-compose-ec2.yml up -d --build

# View logs
docker-compose -f docker-compose-ec2.yml logs -f kafkaproducer

# Stop
docker-compose -f docker-compose-ec2.yml down

# Restart
docker-compose -f docker-compose-ec2.yml restart

# Clean everything
docker-compose -f docker-compose-ec2.yml down -v
docker system prune -a
```

---

## Next Steps

1. ✅ Deploy using Docker Compose
2. ✅ Configure monitoring and alerting
3. ✅ Set up automated backups
4. ✅ Implement CI/CD pipeline
5. ✅ Scale with Docker Swarm or Kubernetes (advanced)

**Your Docker deployment is ready! 🐳**

