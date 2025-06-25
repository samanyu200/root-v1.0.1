# 🐧 Ubuntu 22.04 VM via Docker (root-v1.1.1)

> 🚀 Create a full Ubuntu 22.04 VPS in your browser with **web-based UI**, **SSH**, and **persistent storage**.  
> ✅ Ideal for use in GitHub Codespaces, CodeSandbox, Gitpod, Deepnote, and Colab!

---

## 🌟 Features

- 🌐 **Web-based VNC access** (via port `6080`)
- 🔑 **SSH access** (via port `2221`, tunneled with Playit.gg)
- 💾 **Persistent storage** with Docker volumes
- 🧰 Easily install panels like **Pterodactyl**
- 📜 Open source and modifiable with credits
- 🛠 Root access:  
  - **Username:** `root`  
  - **Password:** `root`

---

## ⚙️ Prerequisites

- 🐳 Docker installed
- ✅ KVM virtualization support
- 🔐 `sudo` or root access (for KVM device permissions)

---

## 📥 Installation Guide

### 1️⃣ Clone the repository

```bash
git clone https://github.com/samanyu200/root-v1.1.1
cd root-v1.1.1
2️⃣ Build the Docker image
bash

docker build -t ubuntu-vm .
3️⃣ Run the VM Container
🐳 Default (NAT Mode)
bash

docker run --privileged -p 6080:6080 -p 2221:2222 -v $PWD/vmdata:/data ubuntu-vm
🐳 Bridged Network Mode (host networking)
bash

docker run --rm --privileged --net=host -v $PWD/vmdata:/data ubuntu-vm
🖥 Accessing the VM
🔗 Web UI (noVNC)
Open in your browser:

bash

http://localhost:6080/vnc.html
🔐 SSH Access (via Playit.gg)
Use the Colab or Deepnote one-liner to instantly get public IPv4 SSH access:

bash

!curl -sL https://raw.githubusercontent.com/samanyu200/root-v1.1.1/main/vps_ssh_playit.sh | bash
✅ You’ll receive an SSH login link (like ssh root@ip.playit.gg -p PORT)

🧩 Pterodactyl Panel Installation (Optional)
You can install the full Pterodactyl Panel inside this VM:

✅ Recommended Setup:
Install Docker inside the VM (apt install docker.io)

Install PHP, MySQL, Composer

Follow official Pterodactyl docs

Use 6080 for accessing your setup via the web

You can also expose ports using Playit or Ngrok for public access.

🆕 Update Info
📦 New file added: updatelog.md
Check that file to see:

Performance improvements ✅

RAM optimizations ✅

Minor bug fixes ✅

🙋 Questions / Support
Feel free to ask on Discord:
📩 @gamer_only99

📜 License & Credits
This project is open for personal use and learning only.

❌ Do NOT fork or copy without permission.

📹 If using in YouTube, TikTok, or any content, credit samanyu200.

📞 Contact on Discord for permission:
