#!/bin/bash

#######################################
# RabbitMQ Producer - EC2 Deployment Script
# For CI/CD Pipeline
#######################################

set -e

echo "=========================================="
echo "RabbitMQ Producer EC2 Deployment"
echo "=========================================="

# Variables
APP_NAME="rabbitmqproducer"
APP_VERSION="0.0.1-SNAPSHOT"
JAR_FILE="${APP_NAME}-${APP_VERSION}.jar"
APP_DIR="/opt/rabbitmqproducer"
SERVICE_USER="rabbitmqapp"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

echo -e "${GREEN}Step 1: Installing Java 17 (LTS)...${NC}"
if ! command -v java &> /dev/null; then
    yum update -y
    yum install -y java-17-amazon-corretto-headless
    echo "Java installed successfully"
else
    echo "Java already installed: $(java -version 2>&1 | head -n 1)"
fi

echo -e "${GREEN}Step 2: Installing RabbitMQ...${NC}"
if ! command -v rabbitmq-server &> /dev/null; then
    # Import RabbitMQ signing key
    rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
    rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
    rpm --import https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key

    # Install Erlang
    yum install -y erlang

    # Install RabbitMQ
    wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.0/rabbitmq-server-3.12.0-1.el8.noarch.rpm
    yum install -y rabbitmq-server-3.12.0-1.el8.noarch.rpm

    # Enable and start RabbitMQ
    systemctl enable rabbitmq-server
    systemctl start rabbitmq-server

    # Enable management plugin
    rabbitmq-plugins enable rabbitmq_management

    # Restart to apply changes
    systemctl restart rabbitmq-server

    echo "RabbitMQ installed and started successfully"
else
    echo "RabbitMQ already installed"
    systemctl is-active --quiet rabbitmq-server || systemctl start rabbitmq-server
fi

echo -e "${GREEN}Step 3: Creating application user...${NC}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false $SERVICE_USER
    echo "User $SERVICE_USER created"
else
    echo "User $SERVICE_USER already exists"
fi

echo -e "${GREEN}Step 4: Creating application directory...${NC}"
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs
mkdir -p $APP_DIR/config
mkdir -p $APP_DIR/data

echo -e "${GREEN}Step 5: Setting permissions...${NC}"
chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR

echo -e "${GREEN}Step 6: Creating systemd service...${NC}"
cat > /etc/systemd/system/rabbitmqproducer.service <<EOF
[Unit]
Description=RabbitMQ Producer Spring Boot Application
After=syslog.target network.target rabbitmq-server.service
Wants=rabbitmq-server.service

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/java -jar $APP_DIR/app.jar --spring.config.location=$APP_DIR/config/application.yml
SuccessExitStatus=143
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=10

# Java options
Environment="JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC"

# RabbitMQ connection (override with environment variables in CI/CD)
Environment="RABBITMQ_HOST=localhost"
Environment="RABBITMQ_PORT=5672"
Environment="RABBITMQ_USERNAME=guest"
Environment="RABBITMQ_PASSWORD=guest"

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}Step 7: Configuring firewall...${NC}"
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --permanent --add-port=5672/tcp
    firewall-cmd --permanent --add-port=15672/tcp
    firewall-cmd --reload
    echo "Firewall configured"
fi

echo -e "${GREEN}Step 8: Reloading systemd...${NC}"
systemctl daemon-reload

echo -e "${GREEN}Step 9: Enabling service...${NC}"
systemctl enable rabbitmqproducer.service

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Service Management Commands:"
echo "  Start:   sudo systemctl start rabbitmqproducer"
echo "  Stop:    sudo systemctl stop rabbitmqproducer"
echo "  Restart: sudo systemctl restart rabbitmqproducer"
echo "  Status:  sudo systemctl status rabbitmqproducer"
echo "  Logs:    sudo journalctl -u rabbitmqproducer -f"
echo ""
echo "Application Details:"
echo "  Directory:  $APP_DIR"
echo "  JAR File:   $APP_DIR/app.jar"
echo "  Config:     $APP_DIR/config/application.yml"
echo "  Port:       8080"
echo ""
echo "RabbitMQ Details:"
echo "  AMQP Port:       5672"
echo "  Management UI:   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):15672"
echo "  Default User:    guest"
echo "  Default Pass:    guest"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Application will be started by CI/CD pipeline"
echo "2. Configure security groups to allow ports 8080, 5672, 15672"
echo "3. Access Swagger UI: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080/swagger-ui.html"
echo ""

