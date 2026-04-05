# 🚀 Quick Start - CI/CD Deployment

## Prerequisites Done ✅
- EC2 Instance: `ec2-13-222-56-46.compute-1.amazonaws.com`
- Application: Built and ready
- GitHub Account: milind75

---

## 🎯 5-Minute Setup

### Step 1: Create GitHub Repository (2 min)

```powershell
# In project directory
cd C:\Users\milin\IdeaProjects\kafkaproducer

# Initialize git
git init
git add .
git commit -m "Initial commit - RabbitMQ Producer"

# Create repo on GitHub
# Go to: https://github.com/new
# Name: rabbitmq-producer
# Click "Create repository"

# Add remote and push
git remote add origin https://github.com/milind75/rabbitmq-producer.git
git branch -M main
git push -u origin main
```

---

### Step 2: Add GitHub Secrets (2 min)

Go to: https://github.com/milind75/rabbitmq-producer/settings/secrets/actions

Add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `EC2_SSH_KEY` | Your EC2 private key (entire .pem file content) |
| `RABBITMQ_HOST` | `localhost` |
| `RABBITMQ_USERNAME` | `guest` |
| `RABBITMQ_PASSWORD` | `guest` |

**Get SSH key content:**
```powershell
Get-Content path\to\your-ec2-key.pem | Out-String
```

---

### Step 3: Configure EC2 Security Group (1 min)

Add these inbound rules:

| Port | Description |
|------|-------------|
| 22 | SSH |
| 8080 | Application |
| 5672 | RabbitMQ AMQP |
| 15672 | RabbitMQ Management |

Source: `0.0.0.0/0` (or restrict to your IP for SSH)

---

### Step 4: Deploy! (< 1 min)

```powershell
# Make a small change
echo "# CI/CD Pipeline Active" >> README.md

# Commit and push
git add .
git commit -m "Trigger CI/CD deployment"
git push origin main
```

---

### Step 5: Watch It Deploy

1. Go to: https://github.com/milind75/rabbitmq-producer/actions
2. Click on the running workflow
3. Watch the magic happen! ✨

**Expected Timeline:**
- Build: ~2 minutes
- Deploy: ~3 minutes
- Total: ~5 minutes

---

## ✅ Verify Deployment

After pipeline completes:

```bash
# Health check
curl http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/actuator/health

# Expected: {"status":"UP"}
```

**Open in browser:**
- Swagger UI: http://ec2-13-222-56-46.compute-1.amazonaws.com:8080/swagger-ui.html
- RabbitMQ UI: http://ec2-13-222-56-46.compute-1.amazonaws.com:15672 (guest/guest)

---

## 🔄 From Now On

Every time you push to `main` branch:
1. ✅ Code builds automatically
2. ✅ Tests run
3. ✅ Deploys to EC2
4. ✅ Health check performed
5. ✅ Rollback if failed

**Just push and relax! 😎**

---

## 🆘 Quick Troubleshooting

### Pipeline fails?
- Check: https://github.com/milind75/rabbitmq-producer/actions
- View logs in failed job

### Can't SSH to EC2?
- Check security group allows port 22
- Verify EC2_SSH_KEY secret is correct

### Application won't start?
```bash
ssh -i your-key.pem ec2-user@ec2-13-222-56-46.compute-1.amazonaws.com
sudo journalctl -u rabbitmqproducer -f
```

---

## 📚 Full Documentation

For detailed setup: See `CICD_SETUP_GUIDE.md`

---

**That's it! Your CI/CD pipeline is ready to rock! 🎸**

