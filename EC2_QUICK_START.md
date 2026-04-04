# 🚀 EC2 Deployment - Quick Reference

## Fastest Way to Deploy

### Using PowerShell Script (Windows - Easiest!)

```powershell
# Traditional deployment (systemd service)
.\deploy-ec2.ps1 -EC2Host "your-ec2-ip" -KeyPath "path\to\your-key.pem"

# Docker deployment
.\deploy-ec2.ps1 -EC2Host "your-ec2-ip" -KeyPath "path\to\your-key.pem" -DeploymentMethod "docker"
```

**Example:**
```powershell
.\deploy-ec2.ps1 -EC2Host "54.123.45.67" -KeyPath "C:\keys\my-key.pem"
```

---

## Manual Deployment Steps

### Prerequisites

1. **EC2 Instance Requirements:**
   - Instance Type: t3.medium or higher
   - OS: Amazon Linux 2023
   - Storage: 20 GB minimum
   - Security Group: Ports 22, 8080 open

2. **Local Setup:**
   - Application built: `.\gradlew.bat clean build -x test`
   - SSH key for EC2 access

---

### Method 1: Traditional Deployment (Systemd)

**Step 1: Build and package**
```powershell
cd C:\Users\milin\IdeaProjects\kafkaproducer
.\gradlew.bat clean build -x test

Compress-Archive -Path "build\libs\kafkaproducer-0.0.1-SNAPSHOT.jar", `
                        "deploy-to-ec2.sh", `
                        "application-ec2.yml" `
                 -DestinationPath "kafka-deploy.zip"
```

**Step 2: Transfer to EC2**
```powershell
scp -i your-key.pem kafka-deploy.zip ec2-user@your-ec2-ip:~
```

**Step 3: Deploy on EC2**
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip

# Extract and setup
unzip kafka-deploy.zip
mkdir -p build/libs src/main/resources
mv kafkaproducer-0.0.1-SNAPSHOT.jar build/libs/
mv application-ec2.yml src/main/resources/application.yml

# Deploy
chmod +x deploy-to-ec2.sh
sudo ./deploy-to-ec2.sh

# Start
sudo systemctl start kafkaproducer
sudo systemctl status kafkaproducer
```

**Step 4: Access application**
```
http://your-ec2-ip:8080/swagger-ui.html
```

---

### Method 2: Docker Deployment

**Step 1: Build**
```powershell
.\gradlew.bat clean build -x test
```

**Step 2: Transfer project**
```powershell
Compress-Archive -Path * -DestinationPath kafka-project.zip
scp -i your-key.pem kafka-project.zip ec2-user@your-ec2-ip:~
```

**Step 3: Setup Docker on EC2**
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip

# Extract
unzip kafka-project.zip
cd kafkaproducer

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# IMPORTANT: Logout and login again
exit
```

**Step 4: Start application**
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
cd kafkaproducer

# Start everything (Kafka + App)
docker-compose -f docker-compose-ec2.yml up -d

# Check logs
docker-compose -f docker-compose-ec2.yml logs -f
```

---

## Configuration

### Update Kafka Settings

**Edit on EC2:**

**Traditional:**
```bash
sudo nano /opt/kafkaproducer/config/application.yml
```

**Docker:**
```bash
nano application-ec2.yml
# Then rebuild: docker-compose -f docker-compose-ec2.yml up -d --build
```

**Key settings:**
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092  # Change to your Kafka server
    
kafka:
  topic:
    name: ordersTopic  # Change topic name if needed
```

---

## Management Commands

### Traditional Deployment

```bash
# Start
sudo systemctl start kafkaproducer

# Stop
sudo systemctl stop kafkaproducer

# Restart
sudo systemctl restart kafkaproducer

# Status
sudo systemctl status kafkaproducer

# Logs
sudo journalctl -u kafkaproducer -f
tail -f /opt/kafkaproducer/logs/application.log
```

### Docker Deployment

```bash
# Start
docker-compose -f docker-compose-ec2.yml up -d

# Stop
docker-compose -f docker-compose-ec2.yml down

# Restart
docker-compose -f docker-compose-ec2.yml restart

# Logs
docker-compose -f docker-compose-ec2.yml logs -f kafkaproducer

# Rebuild
docker-compose -f docker-compose-ec2.yml up -d --build
```

---

## Testing

### Health Check
```bash
curl http://localhost:8080/actuator/health
```

### Send Test Message
```bash
curl -X POST "http://localhost:8080/api/kafka/send?message=TestFromEC2"
```

### Verify in Kafka

**Traditional:**
```bash
cd /opt/kafka
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic ordersTopic --from-beginning
```

**Docker:**
```bash
docker exec -it kafka bash
kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic ordersTopic --from-beginning
```

---

## Troubleshooting

### Application won't start

**Check logs:**
```bash
# Traditional
sudo journalctl -u kafkaproducer -n 50

# Docker
docker logs kafkaproducer
```

### Can't access from browser

1. Check security group allows port 8080
2. Check application is running:
   ```bash
   sudo netstat -tlnp | grep 8080
   ```

### Kafka connection issues

1. Verify Kafka is running:
   ```bash
   # Traditional
   jps | grep Kafka
   
   # Docker
   docker ps | grep kafka
   ```

2. Check bootstrap-servers configuration
3. Test connectivity:
   ```bash
   telnet localhost 9092
   ```

---

## File Reference

| File | Purpose |
|------|---------|
| `deploy-ec2.ps1` | Automated deployment from Windows |
| `deploy-to-ec2.sh` | EC2 setup script (runs on EC2) |
| `application-ec2.yml` | Production configuration |
| `Dockerfile` | Docker container definition |
| `docker-compose-ec2.yml` | Multi-container orchestration |
| `EC2_DEPLOYMENT_GUIDE.md` | Complete guide (70+ pages) |
| `DOCKER_DEPLOYMENT.md` | Docker-specific guide |

---

## Security Checklist

Before production:

- [ ] Change default ports
- [ ] Enable HTTPS/SSL
- [ ] Restrict security group (specific IPs only)
- [ ] Disable H2 console (already done)
- [ ] Use AWS Secrets Manager
- [ ] Enable CloudWatch logging
- [ ] Set up backup strategy
- [ ] Configure monitoring/alerts

---

## Quick Links

Once deployed, access:

- **Swagger UI**: `http://your-ec2-ip:8080/swagger-ui.html`
- **Health Check**: `http://your-ec2-ip:8080/actuator/health`
- **API Docs**: `http://your-ec2-ip:8080/api-docs`
- **Metrics**: `http://your-ec2-ip:8080/actuator/metrics`

---

## Need Help?

1. **Check logs** (see Management Commands above)
2. **Read full documentation**:
   - `EC2_DEPLOYMENT_GUIDE.md` - Complete guide
   - `DOCKER_DEPLOYMENT.md` - Docker specifics
   - `DEPLOYMENT_SUMMARY.md` - Overview
3. **Verify prerequisites** (Java version, Kafka running, etc.)

---

## Cost Estimate

**t3.medium EC2 instance** (recommended):
- ~$30/month (on-demand)
- ~$18/month (1-year reserved)
- ~$8/month (3-year reserved)

**Stop instance when not in use to save costs!**

```bash
# Stop instance
aws ec2 stop-instances --instance-ids i-xxxxx

# Start instance
aws ec2 start-instances --instance-ids i-xxxxx
```

---

## Summary

✅ **7 deployment files created**  
✅ **2 deployment methods available**  
✅ **Complete documentation (70+ pages)**  
✅ **Automated PowerShell script**  
✅ **Production-ready configuration**  
✅ **Docker support included**  
✅ **Security best practices**  

**You're ready to deploy! Choose a method and follow the steps above.** 🚀

