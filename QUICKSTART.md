# ⚡ Quick Start Guide - Joy VPS Manager

Get up and running in 5 minutes!

## 🎯 Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Python 3.10+
- Discord bot token
- Your Discord user ID

## 🚀 Installation (Automatic)

```bash
# 1. Clone repository
git clone https://github.com/yourusername/vps-manager-bot.git
cd vps-manager-bot

# 2. Run installer
chmod +x install.sh
./install.sh

# 3. Done! The script will guide you through setup
```

## 🔧 Installation (Manual)

### Step 1: Install Dependencies

```bash
# System packages
sudo apt update
sudo apt install -y qemu-system-x86-64 cloud-image-utils python3-pip

# Python packages
pip3 install -r requirements.txt
```

### Step 2: Configure Bot

```bash
# Copy example config
cp .env.example .env

# Edit configuration
nano .env
```

**Minimum required configuration:**
```bash
BOT_TOKEN=your_discord_bot_token_here
OWNER_ID=your_discord_user_id_here
```

### Step 3: Get Discord Bot Token

1. Go to https://discord.com/developers/applications
2. Click "New Application"
3. Go to "Bot" section
4. Click "Reset Token" and copy it
5. Enable these Intents:
   - Server Members Intent ✅
   - Message Content Intent ✅
6. Go to OAuth2 > URL Generator
7. Select: `bot` + `applications.commands`
8. Select permissions: `Administrator`
9. Copy URL and invite bot to your server

### Step 4: Get Your User ID

1. Open Discord
2. Settings > Advanced > Enable Developer Mode
3. Right-click your profile > Copy User ID
4. Paste in `.env` as `OWNER_ID`

### Step 5: Run Bot

```bash
# Start bot
python3 vps_bot.py

# Or use screen for background
screen -S vps-bot
python3 vps_bot.py
# Press Ctrl+A then D to detach
```

## 📱 First Commands

Once bot is online in your Discord server:

```
1. /help                          - See all commands
2. /system_check                  - Verify installation
3. /create_vps                    - Create your first VPS
   memory: 2048
   cpus: 2
   disk: 20G
   os_type: Ubuntu 22.04 LTS
4. /start_vps vps_id:vps_xxx      - Start the VPS
5. /vps_shell vps_id:vps_xxx      - Get SSH details
```

## 🔑 Connecting to VPS

After starting VPS, wait 30-60 seconds, then:

```bash
# Get connection details
/vps_shell vps_id:your_vps_id

# Connect via SSH (from command output)
ssh -p 2222 ubuntu@localhost

# Or use one-liner with password
sshpass -p 'password' ssh -p 2222 ubuntu@localhost
```

## ⚙️ Configuration Options

Edit `.env` file:

```bash
# Required
BOT_TOKEN=your_token              # Discord bot token
OWNER_ID=123456789                # Your Discord user ID

# Optional
ADMIN_ROLE_ID=987654321           # Role ID for admins (0 = disabled)
DEFAULT_HOSTNAME=localhost        # SSH hostname
MAX_VPS_PER_USER=5               # VPS limit per user
VM_DIR=/home/user/vms            # VPS storage directory
```

## 🎨 VPS Options

| Setting | Minimum | Maximum | Default |
|---------|---------|---------|---------|
| Memory | 512 MB | 8192 MB | 2048 MB |
| CPUs | 1 | 8 | 2 |
| Disk | 1G | 100G | 20G |

## 🐧 Available OS

- 🐧 Ubuntu 22.04 LTS
- 🐧 Ubuntu 24.04 LTS
- 🌀 Debian 11 (Bullseye)
- 🌀 Debian 12 (Bookworm)
- 🎩 Fedora 40
- 💼 CentOS Stream 9
- 🔷 AlmaLinux 9
- ⛰️ Rocky Linux 9

## 📊 Common Tasks

### Create VPS
```
/create_vps memory:2048 cpus:2 disk:20G os_type:Ubuntu 22.04 LTS
```

### List Your VPS
```
/list
```

### Start VPS
```
/start_vps vps_id:vps_abc123
```

### Stop VPS
```
/stop_vps vps_id:vps_abc123
```

### Restart VPS
```
/restart_vps vps_id:vps_abc123
```

### View Stats
```
/vps_stats vps_id:vps_abc123
```

### Check Logs
```
/vps_logs vps_id:vps_abc123 lines:50
```

### Get SSH Info
```
/vps_shell vps_id:vps_abc123
```

### Change Password
```
/change_pass vps_id:vps_abc123
```

### Delete VPS
```
/delete_vps vps_id:vps_abc123
```

## 👑 Admin Commands

Grant admin to users:
```
/add_admin user:@username
```

View all VPS:
```
/admin_list
```

System stats:
```
/admin_stats
```

Ban user:
```
/ban_user user:@username reason:Abuse
```

Check system:
```
/system_check
```

Clean files:
```
/cleanup
```

## 🐛 Troubleshooting

### Bot doesn't start
```bash
# Check Python version
python3 --version

# Check dependencies
pip3 list | grep discord

# Check logs
cat vps_manager.log
```

### VPS won't start
```bash
# Verify QEMU installed
which qemu-system-x86_64

# Check VPS files
ls -la ~/vms/

# Use system check
/system_check
```

### Can't connect via SSH
```bash
# Check if VPS is running
/vps_stats vps_id:your_id

# Check logs
/vps_logs vps_id:your_id

# Verify port
ss -tlnp | grep 2222
```

## 💡 Pro Tips

1. **First VPS takes 50s** (downloads OS image)
2. **Subsequent VPS take 5s** (uses cache)
3. **Wait 30-60s after start** for OS to boot
4. **Use /vps_logs** to debug boot issues
5. **Minimum 1G disk** to avoid warnings
6. **Cache files preserved** during cleanup
7. **VPS limit per user** (default: 5)
8. **Admins bypass limits**

## 🔧 Advanced Setup

### Run as Systemd Service

```bash
# Create service file
sudo nano /etc/systemd/system/vps-manager.service
```

```ini
[Unit]
Description=HOPINGBOYZ VPS Manager Bot
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/path/to/vps-manager-bot
ExecStart=/usr/bin/python3 /path/to/vps-manager-bot/vps_bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable vps-manager
sudo systemctl start vps-manager

# Check status
sudo systemctl status vps-manager

# View logs
sudo journalctl -u vps-manager -f
```

### Custom VM Directory

```bash
# Edit .env
VM_DIR=/mnt/storage/vps

# Create directory
mkdir -p /mnt/storage/vps

# Set permissions
chmod 755 /mnt/storage/vps
```

### Backup Database

```bash
# Backup
cp vps_manager.db vps_manager.db.backup

# Restore
cp vps_manager.db.backup vps_manager.db

# Auto-backup (cron)
0 0 * * * cp ~/vps-manager-bot/vps_manager.db ~/backups/vps_$(date +\%Y\%m\%d).db
```

## 📚 Next Steps

- Read full documentation: `README.md`
- Check what's new: `CHANGELOG.md`
- Join support server: [Discord Link]
- Report issues: [GitHub Issues]

## 🎉 Success!

You're all set! Create your first VPS with:

```
/create_vps memory:2048 cpus:2 disk:20G os_type:Ubuntu 22.04 LTS
```

Then start it and connect:

```
/start_vps vps_id:your_vps_id
/vps_shell vps_id:your_vps_id
```

---

**Need help?** Check `vps_manager.log` or use `/system_check`

**Made with ❤️ by HOPINGBOYZ**
