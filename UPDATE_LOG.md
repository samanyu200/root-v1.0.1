# 🛠️ Update Log - Ubuntu 22.04 VM Builder

## 📅 22 June 2025 - Performance Upgrade Release

### ✅ Improvements:
- ⚡ **Significantly improved VM performance**
  - Optimized QEMU/KVM boot parameters for faster startup.
  - Enabled hardware virtualization (`-enable-kvm`, `-cpu host`) for better efficiency.

- 🧠 **Increased RAM Allocation**
  - Default memory increased from `2 GB` to `6 GB` for smoother multitasking.
  - Helps run heavier apps inside the VM like Docker, VSCode, or web servers.

- 🔌 **Better Networking Support**
  - Added option to switch between **NAT** and **Bridged** networking using environment variables.
  - More flexibility for advanced users and SSH access.

- 🖥️ **Improved UI**
  - Cleaner output messages.
  - noVNC now runs on port `6080` with easier access at `/vnc.html`.

### 🚧 Known Limitations:
- Bridged mode may not work in cloud IDEs like Codespaces/Gitpod without extra setup.
- VNC may lag slightly if used in low-resource environments.

### 📌 Next Plans (Coming Soon):
- Add terminal-based UI buttons for: Start / Stop / Restart
- Auto network bridge detection and fallback
- VM monitoring panel (CPU/RAM usage)

---

💬 For feedback, suggestions, or permission to reuse this project, contact:  
**Discord** → `@gamer_only99`

