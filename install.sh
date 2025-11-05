#!/bin/bash

# ============================================
# 🚀 HOPINGBOYZ VPS Manager - Quick Install
# ============================================

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║      🚀 Joy VPS MANAGER - INSTALLATION SCRIPT         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ This script should NOT be run as root${NC}"
   echo -e "${YELLOW}Please run as normal user (it will ask for sudo when needed)${NC}"
   exit 1
fi

echo -e "${BLUE}[1/7]${NC} Checking system requirements..."

# Check OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo -e "${GREEN}✅${NC} Detected: $PRETTY_NAME"
else
    echo -e "${RED}❌${NC} Cannot detect OS"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
REQUIRED_VERSION="3.10"

if [[ $(echo -e "$PYTHON_VERSION\n$REQUIRED_VERSION" | sort -V | head -n1) == "$REQUIRED_VERSION" ]]; then
    echo -e "${GREEN}✅${NC} Python $PYTHON_VERSION (>= $REQUIRED_VERSION required)"
else
    echo -e "${RED}❌${NC} Python $PYTHON_VERSION is too old (>= $REQUIRED_VERSION required)"
    exit 1
fi

# Check CPU virtualization
echo -e "\n${BLUE}[2/7]${NC} Checking CPU virtualization support..."
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
    VT_COUNT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
    echo -e "${GREEN}✅${NC} CPU virtualization supported ($VT_COUNT cores)"
else
    echo -e "${YELLOW}⚠️${NC}  CPU virtualization not detected (VPS will be slower)"
fi

# Install system packages
echo -e "\n${BLUE}[3/7]${NC} Installing system packages..."
echo -e "${YELLOW}This will require sudo password${NC}"

if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
    sudo apt update
    sudo apt install -y qemu-system-x86-64 cloud-image-utils python3-pip
elif [[ "$ID" == "fedora" ]]; then
    sudo dnf install -y qemu-system-x86 cloud-utils python3-pip
elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]]; then
    sudo yum install -y qemu-kvm cloud-utils python3-pip
else
    echo -e "${RED}❌${NC} Unsupported OS. Please install manually:"
    echo "  - qemu-system-x86-64"
    echo "  - cloud-image-utils"
    echo "  - python3-pip"
    exit 1
fi

echo -e "${GREEN}✅${NC} System packages installed"

# Install Python dependencies
echo -e "\n${BLUE}[4/7]${NC} Installing Python dependencies..."
pip3 install -r requirements.txt --user

echo -e "${GREEN}✅${NC} Python packages installed"

# Setup environment
echo -e "\n${BLUE}[5/7]${NC} Setting up environment..."

if [[ ! -f .env ]]; then
    cp .env.example .env
    echo -e "${GREEN}✅${NC} Created .env file"
    
    # Interactive setup
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📝 Configuration Setup${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Get bot token
    echo -e "\n${BLUE}Enter your Discord Bot Token:${NC}"
    echo -e "${YELLOW}(Get it from https://discord.com/developers/applications)${NC}"
    read -r BOT_TOKEN
    sed -i "s/BOT_TOKEN=YOUR_BOT_TOKEN_HERE/BOT_TOKEN=$BOT_TOKEN/" .env
    
    # Get owner ID
    echo -e "\n${BLUE}Enter your Discord User ID:${NC}"
    echo -e "${YELLOW}(Right-click your profile > Copy User ID)${NC}"
    echo -e "${YELLOW}(Enable Developer Mode in Discord Settings if needed)${NC}"
    read -r OWNER_ID
    sed -i "s/OWNER_ID=YOUR_USER_ID_HERE/OWNER_ID=$OWNER_ID/" .env
    
    # Optional: hostname
    echo -e "\n${BLUE}Enter SSH hostname (press Enter for 'localhost'):${NC}"
    read -r HOSTNAME
    if [[ -n "$HOSTNAME" ]]; then
        sed -i "s/DEFAULT_HOSTNAME=localhost/DEFAULT_HOSTNAME=$HOSTNAME/" .env
    fi
    
    # Optional: VPS limit
    echo -e "\n${BLUE}Enter max VPS per user (press Enter for '5'):${NC}"
    read -r VPS_LIMIT
    if [[ -n "$VPS_LIMIT" ]]; then
        sed -i "s/MAX_VPS_PER_USER=5/MAX_VPS_PER_USER=$VPS_LIMIT/" .env
    fi
    
    echo -e "\n${GREEN}✅${NC} Configuration saved to .env"
else
    echo -e "${YELLOW}⚠️${NC}  .env file already exists, skipping setup"
fi

# Create VM directory
echo -e "\n${BLUE}[6/7]${NC} Creating VM directory..."
VM_DIR=$(grep VM_DIR .env | cut -d '=' -f2)
if [[ -z "$VM_DIR" ]]; then
    VM_DIR="$HOME/vms"
fi

mkdir -p "$VM_DIR"
echo -e "${GREEN}✅${NC} Created directory: $VM_DIR"

# Create systemd service (optional)
echo -e "\n${BLUE}[7/7]${NC} Would you like to create a systemd service? (y/N)"
read -r CREATE_SERVICE

if [[ "$CREATE_SERVICE" =~ ^[Yy]$ ]]; then
    SERVICE_FILE="/etc/systemd/system/vps-manager.service"
    WORK_DIR=$(pwd)
    
    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=HOPINGBOYZ VPS Manager Discord Bot
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$WORK_DIR
ExecStart=$(which python3) $WORK_DIR/vps_bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable vps-manager.service
    
    echo -e "${GREEN}✅${NC} Systemd service created"
    echo -e "${YELLOW}Start with: sudo systemctl start vps-manager${NC}"
    echo -e "${YELLOW}Check status: sudo systemctl status vps-manager${NC}"
    echo -e "${YELLOW}View logs: sudo journalctl -u vps-manager -f${NC}"
fi

# Summary
echo -e "\n╔════════════════════════════════════════════════════════╗"
echo -e "║  ${GREEN}✅ INSTALLATION COMPLETE!${NC}                          ║"
echo -e "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo ""
echo -e "1. ${GREEN}Review your configuration:${NC}"
echo -e "   cat .env"
echo ""
echo -e "2. ${GREEN}Start the bot:${NC}"
if [[ "$CREATE_SERVICE" =~ ^[Yy]$ ]]; then
    echo -e "   sudo systemctl start vps-manager"
    echo -e "   sudo systemctl status vps-manager"
else
    echo -e "   python3 vps_bot.py"
fi
echo ""
echo -e "3. ${GREEN}Check logs:${NC}"
echo -e "   tail -f vps_manager.log"
echo ""
echo -e "4. ${GREEN}Test in Discord:${NC}"
echo -e "   /help"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📚 Documentation:${NC} Check README.md for full guide"
echo -e "${BLUE}🐛 Issues:${NC} Check vps_manager.log for errors"
echo -e "${BLUE}💡 Tips:${NC} Use /system_check command to verify setup"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}🎉 Happy VPS managing!${NC}"
echo ""
