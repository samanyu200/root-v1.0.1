#!/bin/bash

echo "[*] Installing required tools..."
sudo apt update
sudo apt install -y proot wget tar

echo "[*] Downloading minimal Linux rootfs (Debian)..."
wget https://raw.githubusercontent.com/proot-me/proot/master/examples/debian-wheezy-rootfs.tar.gz -O rootfs.tar.gz
mkdir rootfs
tar -xzf rootfs.tar.gz -C rootfs

echo "[*] Setup complete. Use ./run.sh to enter fake root."
