#!/bin/bash

echo "[*] Launching fake root shell with proot..."
proot -S rootfs /bin/bash

