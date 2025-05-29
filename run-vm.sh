#!/bin/bash

# Start QEMU VM in background
qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  -net nic \
  -net user,hostfwd=tcp::22-:22 \
  -drive file=jammy-server-cloudimg-amd64.img,format=qcow2 \
  -cdrom seed.iso \
  -nographic \
  -enable-kvm &

# Wait for VM boot
echo "⌛ Waiting 25s for VM to boot..."
sleep 25

# Start ttyd on port 3000
ttyd -p 3000 ssh -o StrictHostKeyChecking=no root@localhost &

# Expose ttyd with ngrok
echo "🌍 Exposing port 3000 with ngrok..."
./ngrok http 3000 > /dev/null &

# Wait a few seconds and show public URL
sleep 5
curl --silent http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^"]*'
