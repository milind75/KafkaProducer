# RabbitMQ Connection Diagnostic and Fix Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RabbitMQ Connection Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test port 5672
Write-Host "[1/4] Testing AMQP port 5672..." -ForegroundColor Yellow
$test5672 = Test-NetConnection -ComputerName localhost -Port 5672 -WarningAction SilentlyContinue
if ($test5672.TcpTestSucceeded) {
    Write-Host "✓ Port 5672 is accessible" -ForegroundColor Green
} else {
    Write-Host "✗ Port 5672 is NOT accessible" -ForegroundColor Red
}

# Test port 15672
Write-Host "[2/4] Testing Management UI port 15672..." -ForegroundColor Yellow
$test15672 = Test-NetConnection -ComputerName localhost -Port 15672 -WarningAction SilentlyContinue
if ($test15672.TcpTestSucceeded) {
    Write-Host "✓ Port 15672 is accessible" -ForegroundColor Green
} else {
    Write-Host "✗ Port 15672 is NOT accessible" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/4] Checking what's listening on these ports..." -ForegroundColor Yellow
$ports = netstat -ano | Select-String "5672|15672"
if ($ports) {
    Write-Host $ports
} else {
    Write-Host "No processes found listening on ports 5672 or 15672" -ForegroundColor Red
}

Write-Host ""
Write-Host "[4/4] Diagnosis:" -ForegroundColor Yellow
Write-Host ""

if ($test5672.TcpTestSucceeded -and $test15672.TcpTestSucceeded) {
    Write-Host "✓ RabbitMQ is properly configured!" -ForegroundColor Green
    Write-Host "You can run your application with:" -ForegroundColor Green
    Write-Host "  .\gradlew.bat bootRun" -ForegroundColor White
} elseif ($test15672.TcpTestSucceeded -and -not $test5672.TcpTestSucceeded) {
    Write-Host "✗ Problem Found: Port 5672 (AMQP) is not exposed" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION:" -ForegroundColor Yellow
    Write-Host "Your RabbitMQ is running but port 5672 is not accessible." -ForegroundColor White
    Write-Host ""
    Write-Host "To fix this, you need to restart RabbitMQ with port 5672 exposed." -ForegroundColor White
    Write-Host ""
    Write-Host "Open Docker Desktop and:" -ForegroundColor Cyan
    Write-Host "  1. Stop and delete the current 'rabbitmq' container" -ForegroundColor White
    Write-Host "  2. Run this command in PowerShell:" -ForegroundColor White
    Write-Host ""
    Write-Host "     docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management-alpine" -ForegroundColor Green
    Write-Host ""
    Write-Host "  3. Wait 10 seconds, then run this script again to verify" -ForegroundColor White
} else {
    Write-Host "✗ RabbitMQ is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start RabbitMQ using Docker:" -ForegroundColor White
    Write-Host "  docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management-alpine" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "For detailed help, see: RABBITMQ_CONNECTION_FIX.md" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

