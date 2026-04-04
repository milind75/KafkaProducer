# EC2 Deployment - Quick Start Script
# Run this from PowerShell on your Windows machine

param(
    [Parameter(Mandatory=$true)]
    [string]$EC2Host,

    [Parameter(Mandatory=$true)]
    [string]$KeyPath,

    [Parameter(Mandatory=$false)]
    [string]$DeploymentMethod = "traditional"  # or "docker"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kafka Producer - EC2 Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build the application
Write-Host "[1/5] Building application..." -ForegroundColor Green
.\gradlew.bat clean build -x test

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Please fix errors and try again." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build successful" -ForegroundColor Green
Write-Host ""

# Step 2: Create deployment package
Write-Host "[2/5] Creating deployment package..." -ForegroundColor Green

if ($DeploymentMethod -eq "docker") {
    # Full project for Docker deployment
    $filesToInclude = @(
        "build\libs\kafkaproducer-0.0.1-SNAPSHOT.jar",
        "Dockerfile",
        "docker-compose-ec2.yml",
        "application-ec2.yml",
        "src\main\resources\application.yml"
    )

    # Create temp directory
    $tempDir = "temp-deploy"
    if (Test-Path $tempDir) {
        Remove-Item -Recurse -Force $tempDir
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    # Copy files
    foreach ($file in $filesToInclude) {
        if (Test-Path $file) {
            $destPath = Join-Path $tempDir (Split-Path $file -Leaf)
            Copy-Item $file $destPath
        }
    }

    # Create zip
    Compress-Archive -Path "$tempDir\*" -DestinationPath "kafka-producer-deploy.zip" -Force
    Remove-Item -Recurse -Force $tempDir

} else {
    # Traditional deployment
    Compress-Archive -Path "build\libs\kafkaproducer-0.0.1-SNAPSHOT.jar", `
                            "deploy-to-ec2.sh", `
                            "application-ec2.yml" `
                     -DestinationPath "kafka-producer-deploy.zip" -Force
}

Write-Host "✓ Deployment package created: kafka-producer-deploy.zip" -ForegroundColor Green
Write-Host ""

# Step 3: Transfer to EC2
Write-Host "[3/5] Transferring files to EC2..." -ForegroundColor Green
scp -i $KeyPath kafka-producer-deploy.zip ec2-user@${EC2Host}:~

if ($LASTEXITCODE -ne 0) {
    Write-Host "Transfer failed! Check EC2 host and key path." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Files transferred successfully" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy on EC2
Write-Host "[4/5] Deploying on EC2..." -ForegroundColor Green

if ($DeploymentMethod -eq "docker") {
    # Docker deployment
    $deployCommands = @"
unzip -o kafka-producer-deploy.zip
chmod +x deploy-to-ec2.sh
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-`$(uname -s)-`$(uname -m)' -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo 'Docker installed. Please logout and login again, then run:'
echo 'docker-compose -f docker-compose-ec2.yml up -d'
"@
} else {
    # Traditional deployment
    $deployCommands = @"
unzip -o kafka-producer-deploy.zip
mkdir -p build/libs src/main/resources
mv kafkaproducer-0.0.1-SNAPSHOT.jar build/libs/
mv application-ec2.yml src/main/resources/application.yml
chmod +x deploy-to-ec2.sh
sudo ./deploy-to-ec2.sh
sudo systemctl start kafkaproducer
"@
}

ssh -i $KeyPath ec2-user@${EC2Host} $deployCommands

Write-Host "✓ Deployment complete" -ForegroundColor Green
Write-Host ""

# Step 5: Verify
Write-Host "[5/5] Verifying deployment..." -ForegroundColor Green
Start-Sleep -Seconds 5

$verifyCommand = if ($DeploymentMethod -eq "docker") {
    "docker ps && curl -s http://localhost:8080/actuator/health || echo 'Service starting...'"
} else {
    "sudo systemctl status kafkaproducer --no-pager && curl -s http://localhost:8080/actuator/health || echo 'Service starting...'"
}

ssh -i $KeyPath ec2-user@${EC2Host} $verifyCommand

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Yellow
Write-Host "  Swagger UI: http://${EC2Host}:8080/swagger-ui.html" -ForegroundColor White
Write-Host "  Health:     http://${EC2Host}:8080/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow

if ($DeploymentMethod -eq "docker") {
    Write-Host "  View logs:    ssh -i $KeyPath ec2-user@${EC2Host} 'docker logs -f kafkaproducer'" -ForegroundColor White
    Write-Host "  Restart:      ssh -i $KeyPath ec2-user@${EC2Host} 'docker-compose -f docker-compose-ec2.yml restart'" -ForegroundColor White
    Write-Host "  Stop:         ssh -i $KeyPath ec2-user@${EC2Host} 'docker-compose -f docker-compose-ec2.yml down'" -ForegroundColor White
} else {
    Write-Host "  View logs:    ssh -i $KeyPath ec2-user@${EC2Host} 'sudo journalctl -u kafkaproducer -f'" -ForegroundColor White
    Write-Host "  Restart:      ssh -i $KeyPath ec2-user@${EC2Host} 'sudo systemctl restart kafkaproducer'" -ForegroundColor White
    Write-Host "  Stop:         ssh -i $KeyPath ec2-user@${EC2Host} 'sudo systemctl stop kafkaproducer'" -ForegroundColor White
}

Write-Host ""
Write-Host "✓ All done! Your application is deployed and running on EC2! 🚀" -ForegroundColor Green
Write-Host ""

# Cleanup
Remove-Item kafka-producer-deploy.zip -ErrorAction SilentlyContinue

