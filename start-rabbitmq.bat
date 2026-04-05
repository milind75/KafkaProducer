@echo off
echo Starting RabbitMQ with proper ports...

REM Stop any existing RabbitMQ container
docker stop rabbitmq 2>nul
docker rm rabbitmq 2>nul

REM Start RabbitMQ with both ports exposed
docker run -d --name rabbitmq ^
  -p 5672:5672 ^
  -p 15672:15672 ^
  -e RABBITMQ_DEFAULT_USER=guest ^
  -e RABBITMQ_DEFAULT_PASS=guest ^
  rabbitmq:3.12-management-alpine

echo.
echo RabbitMQ is starting...
echo.
echo Waiting 10 seconds for RabbitMQ to be ready...
timeout /t 10 /nobreak >nul

echo.
echo RabbitMQ should now be accessible:
echo   - AMQP Port: localhost:5672
echo   - Management UI: http://localhost:15672 (guest/guest)
echo.
echo You can now run your application with:
echo   gradlew bootRun
echo.

pause

