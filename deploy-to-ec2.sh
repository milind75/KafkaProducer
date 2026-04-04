#!/bin/bash

#######################################
# Kafka Producer - EC2 Deployment Script
#######################################

set -e

echo "=========================================="
echo "Kafka Producer EC2 Deployment"
echo "=========================================="

# Variables
APP_NAME="kafkaproducer"
APP_VERSION="0.0.1-SNAPSHOT"
JAR_FILE="${APP_NAME}-${APP_VERSION}.jar"
APP_DIR="/opt/kafkaproducer"
SERVICE_USER="kafkaapp"

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
# Note: JDK 24 might not be in standard repos, using JDK 17 LTS for production
if ! command -v java &> /dev/null; then
    yum update -y
    yum install -y java-17-amazon-corretto-headless
    echo "Java installed successfully"
else
    echo "Java already installed: $(java -version 2>&1 | head -n 1)"
fi

echo -e "${GREEN}Step 2: Creating application user...${NC}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false $SERVICE_USER
    echo "User $SERVICE_USER created"
else
    echo "User $SERVICE_USER already exists"
fi

echo -e "${GREEN}Step 3: Creating application directory...${NC}"
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs
mkdir -p $APP_DIR/config

echo -e "${GREEN}Step 4: Copying application files...${NC}"
if [ -f "build/libs/$JAR_FILE" ]; then
    cp build/libs/$JAR_FILE $APP_DIR/app.jar
    echo "JAR file copied to $APP_DIR/app.jar"
else
    echo -e "${RED}Error: JAR file not found at build/libs/$JAR_FILE${NC}"
    echo "Please run: ./gradlew clean build -x test"
    exit 1
fi

if [ -f "src/main/resources/application.yml" ]; then
    cp src/main/resources/application.yml $APP_DIR/config/application.yml
    echo "Configuration file copied"
fi

echo -e "${GREEN}Step 5: Setting permissions...${NC}"
chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR
chmod +x $APP_DIR/app.jar

echo -e "${GREEN}Step 6: Creating systemd service...${NC}"
cat > /etc/systemd/system/kafkaproducer.service <<EOF
[Unit]
Description=Kafka Producer Spring Boot Application
After=syslog.target network.target

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

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}Step 7: Reloading systemd...${NC}"
systemctl daemon-reload

echo -e "${GREEN}Step 8: Enabling service...${NC}"
systemctl enable kafkaproducer.service

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Service Management Commands:"
echo "  Start:   sudo systemctl start kafkaproducer"
echo "  Stop:    sudo systemctl stop kafkaproducer"
echo "  Restart: sudo systemctl restart kafkaproducer"
echo "  Status:  sudo systemctl status kafkaproducer"
echo "  Logs:    sudo journalctl -u kafkaproducer -f"
echo ""
echo "Application Details:"
echo "  Directory: $APP_DIR"
echo "  JAR File:  $APP_DIR/app.jar"
echo "  Config:    $APP_DIR/config/application.yml"
echo "  Port:      8080"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Update $APP_DIR/config/application.yml with your Kafka broker address"
echo "2. Configure security groups to allow port 8080"
echo "3. Start the service: sudo systemctl start kafkaproducer"
echo "4. Check status: sudo systemctl status kafkaproducer"
echo ""

