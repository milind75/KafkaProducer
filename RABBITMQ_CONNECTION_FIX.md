# 🔧 RabbitMQ Connection Fix

## Problem
- ✅ RabbitMQ Management UI works on port 15672
- ❌ AMQP port 5672 is NOT accessible
- ❌ Application can't connect

## Solution

You have RabbitMQ running, but port 5672 is not exposed. Here are the solutions:

---

## Option 1: Restart RabbitMQ with Port 5672 Exposed

### If using Docker Desktop:

1. **Open Docker Desktop**

2. **Stop the current RabbitMQ container:**
   - Go to "Containers" tab
   - Find "rabbitmq" container
   - Click Stop icon
   - Click Delete icon

3. **Start new RabbitMQ container with both ports:**
   - Open PowerShell
   - Run this command:
   ```powershell
   docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management-alpine
   ```

4. **Wait 10 seconds** for RabbitMQ to start

5. **Verify both ports:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 5672
   Test-NetConnection -ComputerName localhost -Port 15672
   ```
   Both should show `TcpTestSucceeded : True`

6. **Run your application:**
   ```powershell
   .\gradlew.bat bootRun
   ```

---

## Option 2: Use Different RabbitMQ Host

If RabbitMQ is running on a different machine or container:

1. Find the RabbitMQ host/IP:
   - Check Docker Desktop → Containers → rabbitmq → Inspect
   - Look for IPAddress

2. Update `application.yml`:
   ```yaml
   spring:
     rabbitmq:
       host: <RABBITMQ_IP_ADDRESS>  # Replace with actual IP
       port: 5672
   ```

---

## Option 3: Install RabbitMQ Locally (No Docker)

### Using Chocolatey:

```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install RabbitMQ
choco install rabbitmq -y

# Enable management plugin
rabbitmq-plugins enable rabbitmq_management

# Start RabbitMQ
rabbitmq-server
```

---

## Quick Test After Fix

```powershell
# 1. Test port 5672
Test-NetConnection -ComputerName localhost -Port 5672
# Should show: TcpTestSucceeded : True

# 2. Test Management UI
Start-Process "http://localhost:15672"
# Should open and show login (guest/guest)

# 3. Run application
.\gradlew.bat bootRun

# 4. Test API
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=Test"
```

---

## Recommended: Docker Desktop Approach

**Step-by-step:**

1. Open PowerShell as Administrator

2. Run:
   ```powershell
   docker run -d --name rabbitmq `
     -p 5672:5672 `
     -p 15672:15672 `
     -e RABBITMQ_DEFAULT_USER=guest `
     -e RABBITMQ_DEFAULT_PASS=guest `
     rabbitmq:3.12-management-alpine
   ```

3. Wait 10 seconds

4. Verify:
   ```powershell
   docker ps
   # Should show rabbitmq container with ports 5672 and 15672
   ```

5. Test connection:
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 5672
   # Should show: TcpTestSucceeded : True
   ```

6. Run application:
   ```powershell
   .\gradlew.bat bootRun
   ```

---

## After Fix - Expected Output

When you run `.\gradlew.bat bootRun`, you should see:

```
Started RabbitmqproducerApplication in X.XX seconds
```

No connection errors!

Then test:
```powershell
curl -X POST "http://localhost:8080/api/rabbitmq/send?message=HelloRabbitMQ"
```

Expected response:
```
Message sent successfully to RabbitMQ: HelloRabbitMQ
```

---

## Still Having Issues?

Run this diagnostic:

```powershell
# Check what's listening on ports
netstat -ano | findstr "5672"
netstat -ano | findstr "15672"

# Check Docker containers (if using Docker)
docker ps

# Check RabbitMQ logs (if using Docker)
docker logs rabbitmq
```

Share the output and I'll help further!

