#!/bin/bash
echo "🔧 Setting up your free VPS-like environment..."

# Set root password
echo "root:root" | chpasswd

# Install SSH server and dependencies
apt update -y && apt install -y openssh-server curl unzip net-tools

# Configure SSH to allow root login and password auth
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# Install Playit.gg manually from GitHub
echo "📦 Installing Playit.gg manually..."
cd /usr/local/bin
curl -LO https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
mv playit-linux-amd64 playit
chmod +x playit

# Start Playit
echo ""
echo "📡 Starting Playit tunnel..."
echo "📌 SSH Login: root | Password: root"
echo "✅ You’ll get a public IP and port for SSH access."
playit
