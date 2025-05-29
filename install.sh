#!/bin/bash

# Install dependencies
apt update && apt install -y qemu-system-x86 curl cloud-image-utils net-tools ttyd unzip openssh-client

# Install ngrok if not present
if [ ! -f ./ngrok ]; then
  curl -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -o ngrok.zip
  unzip ngrok.zip
  chmod +x ngrok
fi

# Prompt for NGROK_AUTH_TOKEN (first-time only)
if ! grep -q "authtoken" ~/.ngrok2/ngrok.yml 2>/dev/null; then
  echo "2xfZZqZ1odnoOUAGtxSu0hS2iDW_4Co7nnASzcgTdJsZwMvW1"
  read NGROK_AUTH
  ./ngrok config add-authtoken "$NGROK_AUTH"
fi

# Download Ubuntu image
if [ ! -f jammy-server-cloudimg-amd64.img ]; then
  curl -LO https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
fi

# Create cloud-init config
cat > user-data <<EOF
#cloud-config
chpasswd:
  list: |
    root:root
  expire: False
ssh_pwauth: True
disable_root: false
EOF

cat > meta-data <<EOF
instance-id: iid-local01
local-hostname: ubuntu-vm
EOF

# Create ISO
cloud-localds seed.iso user-data meta-data
