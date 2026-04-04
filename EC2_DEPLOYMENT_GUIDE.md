# EC2 Deployment Guide - Kafka Producer Application

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [EC2 Instance Setup](#ec2-instance-setup)
3. [Kafka Setup on EC2](#kafka-setup-on-ec2)
4. [Application Deployment](#application-deployment)
5. [Security Configuration](#security-configuration)
6. [Monitoring & Troubleshooting](#monitoring--troubleshooting)

---

## Prerequisites

### Local Machine
- ✅ Application built successfully
- ✅ AWS CLI installed and configured
- ✅ SSH key pair for EC2 access

### AWS Account
- ✅ EC2 access permissions
- ✅ Security group configuration access
- ✅ (Optional) Elastic IP for static IP address

---

## EC2 Instance Setup

### Step 1: Launch EC2 Instance

#### Recommended Instance Type:
- **Development/Testing**: `t3.medium` (2 vCPU, 4 GB RAM)
- **Production**: `t3.large` or higher (2 vCPU, 8 GB RAM)

#### AMI Selection:
- **Amazon Linux 2023** (recommended)
- OR **Amazon Linux 2**
- OR **Ubuntu 22.04 LTS**

#### Storage:
- **Root Volume**: 20 GB (minimum)
- **Type**: gp3 (General Purpose SSD)

### Step 2: Configure Security Group

Create a security group with the following inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| HTTP | TCP | 8080 | 0.0.0.0/0 | Application API |
| Custom TCP | TCP | 9092 | Security Group ID | Kafka (if Kafka on same VPC) |
| Custom TCP | TCP | 2181 | Security Group ID | Zookeeper (if needed) |

**Security Group Configuration Example:**
```bash
# Create security group
aws ec2 create-security-group \
  --group-name kafka-producer-sg \
  --description "Security group for Kafka Producer application"

# Add SSH access (replace YOUR_IP)
aws ec2 authorize-security-group-ingress \
  --group-name kafka-producer-sg \
  --protocol tcp --port 22 \
  --cidr YOUR_IP/32

# Add HTTP access for application
aws ec2 authorize-security-group-ingress \
  --group-name kafka-producer-sg \
  --protocol tcp --port 8080 \
  --cidr 0.0.0.0/0

# Add Kafka port (for inter-EC2 communication)
aws ec2 authorize-security-group-ingress \
  --group-name kafka-producer-sg \
  --protocol tcp --port 9092 \
  --source-group kafka-producer-sg
```

### Step 3: Launch Instance

```bash
# Using AWS CLI
aws ec2 run-instances \
  --image-id ami-xxxxxxxxx \
  --count 1 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-groups kafka-producer-sg \
  --block-device-mappings DeviceName=/dev/xvda,Ebs={VolumeSize=20,VolumeType=gp3} \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=kafka-producer-app}]'
```

OR use AWS Console:
1. Go to EC2 Dashboard
2. Click "Launch Instance"
3. Select Amazon Linux 2023
4. Choose `t3.medium`
5. Configure security group as above
6. Launch with your key pair

---

## Kafka Setup on EC2

### Option 1: Install Kafka on Same EC2 Instance

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ec2-user@your-ec2-public-ip

# Install Java
sudo yum update -y
sudo yum install -y java-17-amazon-corretto

# Download Kafka
cd /opt
sudo wget https://downloads.apache.org/kafka/3.6.1/kafka_2.13-3.6.1.tgz
sudo tar -xzf kafka_2.13-3.6.1.tgz
sudo mv kafka_2.13-3.6.1 kafka
sudo chown -R ec2-user:ec2-user /opt/kafka

# Start Zookeeper
cd /opt/kafka
bin/zookeeper-server-start.sh -daemon config/zookeeper.properties

# Start Kafka
bin/kafka-server-start.sh -daemon config/server.properties

# Verify Kafka is running
jps | grep Kafka
```

### Option 2: Use Amazon MSK (Managed Streaming for Kafka)

1. Create MSK cluster in AWS Console
2. Note the bootstrap servers endpoint
3. Update `application-ec2.yml` with MSK endpoint

### Option 3: Use Separate EC2 for Kafka

1. Launch another EC2 instance for Kafka
2. Install Kafka as shown above
3. Update application config with Kafka EC2 private IP

---

## Application Deployment

### Method 1: Automated Deployment Script (Recommended)

#### Step 1: Build Application Locally

```powershell
# On your local Windows machine
cd C:\Users\milin\IdeaProjects\kafkaproducer
.\gradlew.bat clean build -x test
```

#### Step 2: Transfer Files to EC2

```powershell
# Create a deployment package
Compress-Archive -Path build/libs/kafkaproducer-0.0.1-SNAPSHOT.jar, `
                        deploy-to-ec2.sh, `
                        application-ec2.yml `
                 -DestinationPath kafka-producer-deploy.zip

# Transfer to EC2 using SCP
scp -i your-key.pem kafka-producer-deploy.zip ec2-user@your-ec2-ip:~
```

#### Step 3: Deploy on EC2

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Extract deployment package
unzip kafka-producer-deploy.zip
mkdir -p build/libs
mv kafkaproducer-0.0.1-SNAPSHOT.jar build/libs/
mkdir -p src/main/resources
mv application-ec2.yml src/main/resources/application.yml

# Make deployment script executable
chmod +x deploy-to-ec2.sh

# Run deployment script
sudo ./deploy-to-ec2.sh
```

### Method 2: Manual Deployment

```bash
# 1. Install Java
sudo yum update -y
sudo yum install -y java-17-amazon-corretto

# 2. Create application directory
sudo mkdir -p /opt/kafkaproducer/{config,logs}

# 3. Copy JAR file (after uploading via scp)
sudo cp kafkaproducer-0.0.1-SNAPSHOT.jar /opt/kafkaproducer/app.jar

# 4. Create application.yml
sudo nano /opt/kafkaproducer/config/application.yml
# Paste the content from application-ec2.yml

# 5. Create systemd service
sudo nano /etc/systemd/system/kafkaproducer.service
```

**Systemd Service File:**
```ini
[Unit]
Description=Kafka Producer Spring Boot Application
After=syslog.target network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/kafkaproducer
ExecStart=/usr/bin/java -jar /opt/kafkaproducer/app.jar --spring.config.location=/opt/kafkaproducer/config/application.yml
SuccessExitStatus=143
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=10
Environment="JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC"

[Install]
WantedBy=multi-user.target
```

```bash
# 6. Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable kafkaproducer
sudo systemctl start kafkaproducer

# 7. Check status
sudo systemctl status kafkaproducer
```

---

## Configuration

### Update Kafka Bootstrap Servers

Edit `/opt/kafkaproducer/config/application.yml`:

```yaml
spring:
  kafka:
    # For Kafka on same EC2:
    bootstrap-servers: localhost:9092
    
    # For Kafka on different EC2:
    bootstrap-servers: 10.0.1.50:9092  # Use private IP
    
    # For Amazon MSK:
    bootstrap-servers: b-1.msk-cluster.xxxxx.kafka.us-east-1.amazonaws.com:9092
```

### Environment-Based Configuration

You can use environment variables:

```bash
# Set environment variables
sudo nano /etc/systemd/system/kafkaproducer.service

# Add under [Service] section:
Environment="KAFKA_BOOTSTRAP_SERVERS=localhost:9092"
Environment="KAFKA_TOPIC_NAME=ordersTopic"
Environment="SERVER_PORT=8080"
```

Then reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart kafkaproducer
```

---

## Security Configuration

### 1. Application Security

#### Disable H2 Console in Production
Already configured in `application-ec2.yml`:
```yaml
spring:
  h2:
    console:
      enabled: false  # IMPORTANT: Disabled for security
```

#### Enable HTTPS (Optional but Recommended)

1. **Get SSL Certificate** (Let's Encrypt or AWS Certificate Manager)

2. **Configure Spring Boot for HTTPS:**
```yaml
server:
  port: 8443
  ssl:
    key-store: /opt/kafkaproducer/keystore.p12
    key-store-password: ${KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    key-alias: tomcat
```

3. **Update Security Group** to allow port 8443

### 2. AWS Security Best Practices

- ✅ Use IAM roles instead of access keys
- ✅ Enable VPC for network isolation
- ✅ Use private subnets for Kafka
- ✅ Implement least privilege access
- ✅ Enable CloudWatch logging
- ✅ Use AWS Secrets Manager for sensitive data

### 3. Restrict Access

Update security group to allow only specific IPs:
```bash
# Allow access only from your office IP
aws ec2 authorize-security-group-ingress \
  --group-name kafka-producer-sg \
  --protocol tcp --port 8080 \
  --cidr YOUR_OFFICE_IP/32
```

---

## Monitoring & Troubleshooting

### Check Application Status

```bash
# Service status
sudo systemctl status kafkaproducer

# View logs
sudo journalctl -u kafkaproducer -f

# View application logs
tail -f /opt/kafkaproducer/logs/application.log

# Check if application is listening
sudo netstat -tlnp | grep 8080
```

### Health Check Endpoints

```bash
# Health check
curl http://localhost:8080/actuator/health

# Application info
curl http://localhost:8080/actuator/info

# Metrics
curl http://localhost:8080/actuator/metrics
```

### Common Issues

#### Issue 1: Application Won't Start
```bash
# Check Java version
java -version

# Check logs
sudo journalctl -u kafkaproducer -n 100

# Check if port is already in use
sudo lsof -i :8080
```

#### Issue 2: Can't Connect to Kafka
```bash
# Test Kafka connectivity
telnet localhost 9092

# Check Kafka is running
jps | grep Kafka

# View Kafka logs
tail -f /opt/kafka/logs/server.log
```

#### Issue 3: Out of Memory
```bash
# Check system memory
free -h

# Increase Java heap size in service file
sudo nano /etc/systemd/system/kafkaproducer.service

# Update JAVA_OPTS
Environment="JAVA_OPTS=-Xms1024m -Xmx2048m -XX:+UseG1GC"

# Restart
sudo systemctl daemon-reload
sudo systemctl restart kafkaproducer
```

---

## Testing Deployment

### 1. Access Swagger UI

```
http://your-ec2-public-ip:8080/swagger-ui.html
```

### 2. Test API Endpoints

```bash
# Get EC2 public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Test send message
curl -X POST "http://$PUBLIC_IP:8080/api/kafka/send?message=HelloFromEC2"

# Test send message with key
curl -X POST "http://$PUBLIC_IP:8080/api/kafka/send-with-key?key=test&message=HelloFromEC2"
```

### 3. Verify Messages in Kafka

```bash
# On EC2 instance with Kafka
cd /opt/kafka

# Consume messages
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic ordersTopic --from-beginning
```

---

## Backup & Maintenance

### Backup Configuration

```bash
# Backup application config
sudo cp /opt/kafkaproducer/config/application.yml \
       /opt/kafkaproducer/config/application.yml.backup

# Backup database (H2)
sudo cp -r /opt/kafkaproducer/data /opt/kafkaproducer/data-backup
```

### Update Application

```bash
# 1. Build new version locally
.\gradlew.bat clean build -x test

# 2. Transfer to EC2
scp -i your-key.pem build/libs/kafkaproducer-0.0.1-SNAPSHOT.jar \
    ec2-user@your-ec2-ip:~/new-version.jar

# 3. On EC2, stop service
sudo systemctl stop kafkaproducer

# 4. Backup current version
sudo cp /opt/kafkaproducer/app.jar /opt/kafkaproducer/app.jar.old

# 5. Deploy new version
sudo mv ~/new-version.jar /opt/kafkaproducer/app.jar
sudo chown kafkaapp:kafkaapp /opt/kafkaproducer/app.jar

# 6. Start service
sudo systemctl start kafkaproducer

# 7. Verify
sudo systemctl status kafkaproducer
```

---

## Cost Optimization

### 1. Use Reserved Instances or Savings Plans
- Save up to 72% compared to On-Demand pricing

### 2. Right-Size Your Instance
- Monitor CPU/Memory usage
- Scale down if underutilized

### 3. Use Auto-Stop for Dev/Test
```bash
# Stop instance when not in use
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start when needed
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

### 4. Use Spot Instances for Non-Critical Workloads
- Save up to 90% compared to On-Demand

---

## Production Checklist

Before going to production:

- [ ] SSL/HTTPS configured
- [ ] H2 console disabled
- [ ] Security groups properly configured
- [ ] IAM roles assigned (no hardcoded credentials)
- [ ] CloudWatch logging enabled
- [ ] Backup strategy in place
- [ ] Monitoring/alerting configured
- [ ] Load balancer configured (for multiple instances)
- [ ] Auto-scaling group set up (optional)
- [ ] Database moved to RDS/Aurora (if needed)
- [ ] Kafka moved to MSK or dedicated cluster
- [ ] Application logs rotated
- [ ] Health check endpoints working

---

## Quick Reference Commands

```bash
# Service Management
sudo systemctl start kafkaproducer      # Start service
sudo systemctl stop kafkaproducer       # Stop service
sudo systemctl restart kafkaproducer    # Restart service
sudo systemctl status kafkaproducer     # Check status

# Logs
sudo journalctl -u kafkaproducer -f     # Follow service logs
tail -f /opt/kafkaproducer/logs/application.log  # Follow app logs

# Kafka Management
cd /opt/kafka
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic ordersTopic

# Health Checks
curl http://localhost:8080/actuator/health
curl http://localhost:8080/swagger-ui.html
```

---

## Support & Resources

- **AWS Documentation**: https://docs.aws.amazon.com/ec2/
- **Spring Boot Documentation**: https://docs.spring.io/spring-boot/
- **Kafka Documentation**: https://kafka.apache.org/documentation/

---

## Next Steps

1. ✅ Deploy application using automated script
2. ✅ Configure Kafka connection
3. ✅ Test API endpoints via Swagger UI
4. ✅ Set up monitoring and alerts
5. ✅ Plan for scaling and high availability

**Your application is now ready for EC2 deployment! 🚀**

