# CI/CD Pipeline Setup Guide

## 🚀 Complete CI/CD Setup for EC2 Deployment

This guide will help you set up a complete CI/CD pipeline using GitHub Actions to automatically build and deploy your RabbitMQ Producer application to EC2.

---

## 📋 Prerequisites

Before setting up CI/CD, ensure you have:

- [x] GitHub account (username: milind75)
- [x] EC2 instance running (ec2-13-222-56-46.compute-1.amazonaws.com)
- [x] SSH key pair for EC2 access
- [x] GitHub repository created

---

## 🔧 Setup Steps

### Step 1: Prepare EC2 Instance

#### 1.1 Configure Security Group

Add these inbound rules to your EC2 security group:

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| HTTP | TCP | 8080 | 0.0.0.0/0 | Application API |
| Custom TCP | TCP | 5672 | 0.0.0.0/0 | RabbitMQ AMQP |
| Custom TCP | TCP | 15672 | 0.0.0.0/0 | RabbitMQ Management |

**AWS Console Steps:**
1. Go to EC2 Dashboard
2. Select your instance
3. Click "Security" tab
4. Click on the security group
5. Edit "Inbound rules"
6. Add the rules above
7. Save

#### 1.2 Test SSH Access

```bash
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com
```

If successful, you should see the EC2 instance prompt.

---

### Step 2: Initialize Git Repository

```powershell
# Navigate to project
cd C:\Users\milin\IdeaProjects\kafkaproducer

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - RabbitMQ Producer with CI/CD"
```

---

### Step 3: Create GitHub Repository

#### Option A: Using GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `rabbitmq-producer` (or your choice)
3. Description: "RabbitMQ Producer Spring Boot Application with CI/CD"
4. Choose "Public" or "Private"
5. **Don't** initialize with README (you already have one)
6. Click "Create repository"

#### Option B: Using GitHub CLI (if installed)

```powershell
gh repo create rabbitmq-producer --public --source=. --remote=origin --push
```

#### Add Remote and Push

```powershell
# Add remote (replace with your repository URL)
git remote add origin https://github.com/milind75/rabbitmq-producer.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

### Step 4: Set Up GitHub Secrets

You need to add these secrets to your GitHub repository:

#### 4.1 Navigate to Repository Settings

1. Go to your repository on GitHub
2. Click "Settings"
3. Click "Secrets and variables" → "Actions"
4. Click "New repository secret"

#### 4.2 Add Required Secrets

**Secret 1: EC2_SSH_KEY**
- Name: `EC2_SSH_KEY`
- Value: Your EC2 private key content (entire .pem file)

To get your key content:
```powershell
Get-Content your-ec2-key.pem | Out-String
```
Copy the entire output including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`

**Secret 2: RABBITMQ_HOST**
- Name: `RABBITMQ_HOST`
- Value: `localhost` (if RabbitMQ is on same EC2)
- Or: EC2 public IP/hostname if RabbitMQ is elsewhere

**Secret 3: RABBITMQ_USERNAME**
- Name: `RABBITMQ_USERNAME`
- Value: `guest` (default) or your custom username

**Secret 4: RABBITMQ_PASSWORD**
- Name: `RABBITMQ_PASSWORD`
- Value: `guest` (default) or your custom password

---

### Step 5: Test CI/CD Pipeline

#### 5.1 Make a Test Change

```powershell
# Edit a file (e.g., README.md)
echo "# Testing CI/CD Pipeline" >> README.md

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

#### 5.2 Monitor Pipeline

1. Go to your GitHub repository
2. Click "Actions" tab
3. You should see your workflow running
4. Click on the running workflow to see details

#### 5.3 Check Deployment

After the pipeline completes:

```bash
# Check application health
curl http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/actuator/health

# Expected response:
# {"status":"UP","components":{"rabbit":{"status":"UP"}}}
```

Open in browser:
- **Swagger UI**: http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/swagger-ui.html
- **RabbitMQ Management**: http://ec2-13-222-56-46.compute-1.amazonaws.com:15672

---

## 🔄 CI/CD Pipeline Workflow

### What Happens When You Push Code:

```mermaid
graph TD
    A[Push to main branch] --> B[GitHub Actions Triggered]
    B --> C[Build Job]
    C --> D[Checkout Code]
    D --> E[Set up Java 17]
    E --> F[Build with Gradle]
    F --> G[Run Tests]
    G --> H[Upload Artifacts]
    H --> I[Deploy Job]
    I --> J[Download Artifacts]
    J --> K[Configure SSH]
    K --> L[Copy Files to EC2]
    L --> M[Run Deployment Script]
    M --> N[Start Application]
    N --> O[Health Check]
    O --> P{Healthy?}
    P -->|Yes| Q[Deployment Success]
    P -->|No| R[Rollback to Previous Version]
```

### Pipeline Stages:

1. **Build Stage**
   - Checkout code
   - Set up Java 17
   - Build application with Gradle
   - Run tests
   - Upload JAR artifact

2. **Deploy Stage** (only on main branch)
   - Download build artifacts
   - Configure SSH connection
   - Copy files to EC2
   - Stop current application
   - Backup current version
   - Deploy new version
   - Start application
   - Run health check
   - Rollback if failed

---

## 📁 CI/CD Files

| File | Purpose |
|------|---------|
| `.github/workflows/ci-cd.yml` | GitHub Actions pipeline configuration |
| `deploy-to-ec2-cicd.sh` | EC2 deployment script |
| `application-ec2.yml` | Production configuration |

---

## 🛠️ Manual Deployment Commands

If you need to deploy manually:

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com

# Check application status
sudo systemctl status rabbitmqproducer

# View logs
sudo journalctl -u rabbitmqproducer -f

# Restart application
sudo systemctl restart rabbitmqproducer

# View application logs
tail -f /opt/rabbitmqproducer/logs/application.log
```

---

## 🔍 Troubleshooting

### Pipeline Fails at Build Stage

**Check:**
- Build logs in GitHub Actions
- Make sure all dependencies are in `build.gradle`
- Verify Java version compatibility

**Fix:**
```bash
# Test build locally
./gradlew clean build -x test
```

### Pipeline Fails at Deploy Stage

**Check:**
- EC2_SSH_KEY secret is correct
- EC2 instance is running
- Security group allows SSH (port 22)

**Fix:**
```bash
# Test SSH connection
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com
```

### Application Doesn't Start on EC2

**Check:**
- RabbitMQ is running on EC2
- Application logs: `sudo journalctl -u rabbitmqproducer -n 100`
- RabbitMQ logs: `sudo journalctl -u rabbitmq-server -n 100`

**Fix:**
```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com

# Check RabbitMQ status
sudo systemctl status rabbitmq-server

# Start RabbitMQ if not running
sudo systemctl start rabbitmq-server

# Restart application
sudo systemctl restart rabbitmqproducer
```

### Health Check Fails

**Check:**
- Application is running: `sudo systemctl status rabbitmqproducer`
- Port 8080 is accessible
- RabbitMQ connection is working

**Fix:**
```bash
# Check if application is listening
sudo netstat -tlnp | grep 8080

# Check application health
curl http://localhost:8080/actuator/health
```

---

## 🔐 Security Best Practices

### For Production:

1. **Change RabbitMQ Credentials**
   ```bash
   # SSH to EC2
   sudo rabbitmqctl add_user myuser mypassword
   sudo rabbitmqctl set_user_tags myuser administrator
   sudo rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"
   sudo rabbitmqctl delete_user guest
   ```
   
   Update GitHub secrets:
   - `RABBITMQ_USERNAME`: myuser
   - `RABBITMQ_PASSWORD`: mypassword

2. **Restrict Security Group**
   - Change port 8080 source from `0.0.0.0/0` to specific IPs
   - Change port 5672 source to VPC CIDR only
   - Keep port 15672 restricted to your IP

3. **Use HTTPS**
   - Set up SSL certificate (Let's Encrypt or AWS Certificate Manager)
   - Configure ALB/NLB with SSL

4. **Enable VPC**
   - Place EC2 in private subnet
   - Use NAT Gateway for outbound traffic
   - Access via Application Load Balancer

---

## 📊 Monitoring

### GitHub Actions

- View workflow runs: https://github.com/milind75/rabbitmq-producer/actions
- Enable email notifications for failed deployments

### Application Monitoring

```bash
# Health check
curl http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/actuator/health

# Metrics
curl http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/actuator/metrics
```

### RabbitMQ Monitoring

- Management UI: http://ec2-13-222-56-46.compute-1.amazonaws.com:15672
- Check queue depths, message rates, connections

---

## 🔄 Branching Strategy

### Recommended Workflow:

```
main (production)
  ├── develop (staging)
  │   ├── feature/new-endpoint
  │   ├── feature/bug-fix
  │   └── hotfix/critical-fix
```

**Branches:**
- `main`: Auto-deploys to production EC2
- `develop`: Auto-deploys to staging/dev environment
- `feature/*`: Triggers build and test only
- `hotfix/*`: Fast-track to main after review

### Update Workflow for Branches:

Edit `.github/workflows/ci-cd.yml`:

```yaml
on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop
```

---

## 📝 Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] Security group configured
- [ ] GitHub secrets added
- [ ] SSH key works
- [ ] RabbitMQ running on EC2
- [ ] Application configuration updated
- [ ] Database migrations (if any) completed
- [ ] Backup strategy in place
- [ ] Monitoring set up
- [ ] Rollback plan ready

---

## 🎯 Next Steps

1. **Push code to GitHub**
   ```powershell
   git add .
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```

2. **Watch pipeline run** on GitHub Actions tab

3. **Verify deployment** at http://ec2-13-222-56-46.compute-1.amazonaws.com:8080

4. **Test API** using Swagger UI

5. **Set up monitoring** and alerts

---

## 🆘 Support

### Useful Commands:

```bash
# View pipeline logs
# Go to: https://github.com/milind75/rabbitmq-producer/actions

# SSH to EC2
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com

# Check service status
sudo systemctl status rabbitmqproducer

# View application logs
sudo journalctl -u rabbitmqproducer -f

# Restart application
sudo systemctl restart rabbitmqproducer
```

---

## ✅ Success Criteria

Your CI/CD pipeline is working correctly when:

1. ✅ Code push triggers GitHub Actions
2. ✅ Build completes successfully
3. ✅ Tests pass
4. ✅ Application deploys to EC2
5. ✅ Health check returns 200 OK
6. ✅ Swagger UI accessible
7. ✅ API endpoints working
8. ✅ RabbitMQ messages being sent

---

**Your CI/CD pipeline is ready! Push to main branch to trigger deployment! 🚀**

