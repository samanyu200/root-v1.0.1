#!/bin/bash
set -e

# Start API server for UI controls
python3 /server.py &

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

if [ ! -f "$DISK" ]; then
    echo "Creating VM disk..."
    qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
    qemu-img resize "$DISK" 50G
fi

qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -m 6144 \
    -drive file="$DISK",format=raw,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -vga virtio \
    -display vnc=:0 \
    -daemonize

websockify --web=/novnc 6080 localhost:5900 &

echo "🖥️  Web UI at http://localhost:6080/ui-overlay.html"