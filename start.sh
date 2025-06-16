#!/bin/bash
set -e

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

# Set default network mode if not provided
NETWORK_MODE="${NETWORK_MODE:-nat}"

echo "🌐 Using network mode: $NETWORK_MODE"

# Create disk if it doesn't exist
if [ ! -f "$DISK" ]; then
    echo "Creating VM disk..."
    qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
    qemu-img resize "$DISK" 50G
fi

# Build QEMU network flags
if [ "$NETWORK_MODE" = "bridge" ]; then
    # Make sure the bridge exists (default: br0)
    BRIDGE_IF="${BRIDGE_IF:-br0}"
    NET_FLAGS="-netdev bridge,id=net0,br=$BRIDGE_IF -device virtio-net-pci,netdev=net0"
else
    # Default NAT with SSH forwarding
    NET_FLAGS="-netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net,netdev=net0"
fi

# Start VM
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -m 6144 \
    -drive file="$DISK",format=raw,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    $NET_FLAGS \
    -vga virtio \
    -display vnc=:0 \
    -daemonize

# Start noVNC
websockify --web=/novnc 6080 localhost:5900 &

echo "================================================"
echo " 🖥️  VNC: http://localhost:6080/vnc.html"
if [ "$NETWORK_MODE" = "nat" ]; then
    echo " 🔐 SSH: ssh root@localhost -p 2222"
else
    echo " 🔐 SSH available via bridged IP (check 'ip a' inside VM)"
fi
echo " 🧾 Login: root / root"
echo "================================================"

# Wait for SSH port only if in NAT mode
if [ "$NETWORK_MODE" = "nat" ]; then
  for i in {1..30}; do
    nc -z localhost 2222 && echo "✅ VM is ready!" && break
    echo "⏳ Waiting for SSH..."
    sleep 2
  done
fi

wait

