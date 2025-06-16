FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /novnc /opt/qemu /cloud-init

RUN curl -L https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
    -o /opt/qemu/ubuntu.img

RUN echo "instance-id: ubuntu-vm\nlocal-hostname: ubuntu-vm" > /cloud-init/meta-data

RUN printf "#cloud-config\npreserve_hostname: false\nhostname: ubuntu-vm\nusers:\n  - name: root\n    gecos: root\n    shell: /bin/bash\n    lock_passwd: false\n    passwd: $6$abcd1234$W6wzBuvyE.D1mBGAgQw2uvUO/honRrnAGjFhMXSk0LUbZosYtoHy1tUtYhKlALqIldOGPrYnhSrOfAknpm91i0\n    sudo: ALL=(ALL) NOPASSWD:ALL\ndisable_root: false\nssh_pwauth: true\nchpasswd:\n  list: |\n    root:root\n  expire: false\nruncmd:\n  - systemctl enable ssh\n  - systemctl restart ssh\n" > /cloud-init/user-data

RUN genisoimage -output /opt/qemu/seed.iso -volid cidata -joliet -rock \
    /cloud-init/user-data /cloud-init/meta-data

RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-1.3.0/* /novnc && \
    rm -rf /tmp/novnc.zip /tmp/noVNC-1.3.0

COPY start.sh /start.sh
COPY ui-overlay.html /novnc/ui-overlay.html
COPY server.py /server.py

RUN chmod +x /start.sh

VOLUME /data

EXPOSE 6080 2222 8080

CMD ["/start.sh"]