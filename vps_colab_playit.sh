#!/bin/bash
echo "🔧 Setting up your free VPS-like environment..."

# Set root password
echo "root:root" | chpasswd

# Install SSH server and dependencies
apt update -y && apt install -y openssh-server curl unzip

# Configure SSH
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Start SSH
service ssh restart

# Install Playit.gg tunnel
curl -Ss https://playit.gg/install.sh | bash

# Launch Playit to get a public IP/port
echo ""
echo "📡 Starting Playit tunnel..."
echo "📌 Login: root | Password: root"
playit
