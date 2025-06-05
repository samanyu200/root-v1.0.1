FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    cloud-image-utils \
    genisoimage \
    novnc \
    websockify \
    curl \
    unzip \
    openssh-client \
    net-tools \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /data /novnc /opt/qemu /cloud-init

# Download Ubuntu 22.04 cloud image
RUN curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
    -o /opt/qemu/ubuntu.img

# Write meta-data
RUN echo "instance-id: ubuntu-vm\nlocal-hostname: ubuntu-vm" > /cloud-init/meta-data

# Write user-data with working root login and password 'root'
RUN printf "#cloud-config\n\
preserve_hostname: false\n\
hostname: ubuntu-vm\n\
users:\n\
  - name: root\n\
    gecos: root\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: \$6\$abcd1234\$W6wzBuvyE.D1mBGAgQw2uvUO/honRrnAGjFhMXSk0LUbZosYtoHy1tUtYhKlALqIldOGPrYnhSrOfAknpm91i0\n\
    sudo: ALL=(ALL) NOPASSWD:ALL\n\
disable_root: false\n\
ssh_pwauth: true\n\
chpasswd:\n\
  list: |\n\
    root:root\n\
  expire: false\n\
runcmd:\n\
  - systemctl enable ssh\n\
  - systemctl restart ssh\n" > /cloud-init/user-data

# Create cloud-init ISO
RUN genisoimage -output /opt/qemu/seed.iso -volid cidata -joliet -rock \
    /cloud-init/user-data /cloud-init/meta-data

# Setup noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-1.3.0/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-1.3.0

# Start script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

# Create disk if it doesn't exist
if [ ! -f "$DISK" ]; then
    echo "Creating VM disk..."
    qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
    qemu-img resize "$DISK" 50G
fi

# Start VM
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

# Start noVNC
websockify --web=/novnc 6080 localhost:5900 &

echo "================================================"
echo " 🖥️  VNC: http://localhost:6080/vnc.html"
echo " 🔐 SSH: ssh root@localhost -p 2222"
echo " 🧾 Login: root / root"
echo "================================================"

# Wait for SSH port to be ready
for i in {1..30}; do
  nc -z localhost 2222 && echo "✅ VM is ready!" && break
  echo "⏳ Waiting for SSH..."
  sleep 2
done

wait
EOF

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 6080 2222

CMD ["/start.sh"]
