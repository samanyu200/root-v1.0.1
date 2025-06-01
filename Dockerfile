FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    cloud-image-utils \
    genisoimage \
    curl \
    unzip \
    net-tools \
    netcat-openbsd \
    openssh-client \
    cmake \
    g++ \
    git \
    libjson-c-dev \
    libwebsockets-dev \
    libssl-dev \
    libuv1-dev \
    zlib1g-dev \
    pkg-config \
    libsqlite3-dev \
    libssh-dev \
    libwebsockets-dev \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /data /opt/qemu /cloud-init /ttyd

# Install ttyd
RUN git clone https://github.com/tsl0922/ttyd.git /ttyd && \
    cd /ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd / && rm -rf /ttyd

# Download Ubuntu Cloud Image
RUN curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
    -o /opt/qemu/ubuntu.img

# cloud-init config
RUN echo "instance-id: ubuntu-vm\nlocal-hostname: ubuntu-vm" > /cloud-init/meta-data && \
    printf "#cloud-config\n\
preserve_hostname: false\n\
hostname: ubuntu-vm\n\
users:\n\
  - name: root\n\
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

# Start script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e

DISK="/data/vm.raw"
IMG="/opt/qemu/ubuntu.img"
SEED="/opt/qemu/seed.iso"

# Create disk if not exists
if [ ! -f "$DISK" ]; then
    echo "Creating VM disk..."
    qemu-img convert -f qcow2 -O raw "$IMG" "$DISK"
    qemu-img resize "$DISK" 50G
fi

# Start VM with SSH forwarded
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -drive file="$DISK",format=raw,if=virtio \
    -drive file="$SEED",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0 \
    -nographic \
    -daemonize

# Wait for SSH to be ready
for i in {1..30}; do
    nc -z localhost 2222 && echo "✅ SSH is ready!" && break
    echo "⏳ Waiting for SSH..."
    sleep 2
done

# Start ttyd to connect to the VM via SSH
ttyd -p 7681 ssh root@localhost -p 2222
EOF

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 7681 2222

CMD ["/start.sh"]
