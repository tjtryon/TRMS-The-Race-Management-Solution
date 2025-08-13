# 🚀 TRMS GTK4 GUI Launcher
**The one-click control center for The Race Management Solution**

> Modern, polished, and fast — built on **GTK4** + **libadwaita** for a pixel-perfect experience across Wayland and X11.

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue">
  <img alt="GTK" src="https://img.shields.io/badge/GTK-4.0-green">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.8%2B-yellow">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-orange">
</p>

---

## ✨ Why you’ll love it
- **Unified launcher** for the full TRMS suite: **TRRS** (registration), **TRTS** (timing), **TRWS** (web server).  
- **Smart status dashboard** with live environment + directory checks.  
- **Built‑in console** with scrolling, timestamps, and copy-friendly formatting.  
- **Professional UX**: keyboard shortcuts, toast notifications, settings, backups, and more.

---

## 🧭 Table of Contents
- [At a Glance](#-at-a-glance)
- [Quick Start](#-quick-start)
- [Feature Deep Dive](#-feature-deep-dive)
- [Installation](#-installation)
- [Desktop Integration](#-desktop-integration)
- [Configuration](#-configuration)
- [Keyboard Shortcuts](#-keyboard-shortcuts)
- [Troubleshooting](#-troubleshooting)
- [Architecture](#-architecture)
- [Contributing & License](#-contributing--license)
- [Screenshots](#-screenshots)

---

## 📌 At a Glance
| Module | What it does | Launch Modes | Status Indicators |
|---|---|---|---|
| **🏁 TRRS** | Registration (console/GUI) | Local / Virtual Env / Docker | Card badge + console |
| **⏱️ TRTS** | Timing (console/GUI) | Local / Virtual Env / Docker | Card badge + console |
| **🌐 TRWS** | Web server | Local / Docker | Card badge + console |

> The dashboard also surfaces Python env detection, DB connectivity hints, and directory checks for all components.

---

## ⚡ Quick Start
1) **Save** the launcher as `trms_launcher_gui.py` in your TRMS base directory.  
2) **Make it executable** and **run**:
```bash
chmod +x trms_launcher_gui.py
./trms_launcher_gui.py
```

Want verbose logs?
```bash
./trms_launcher_gui.py --debug
```

Specify environment or use cloud DB:
```bash
./trms_launcher_gui.py --env production
USE_CLOUD_DB=true ./trms_launcher_gui.py
```

---

## 🔎 Feature Deep Dive

### 1) Sleek GTK4 + libadwaita UI
- Adaptive layouts, dark/light by system theme
- Custom CSS for refined look & consistent spacing

### 2) Application Cards that *work*
- Each card presents **contextual actions** (e.g., Launch Console / Launch GUI)
- Visual **state badges** reflect availability/health

### 3) Live System Status
- Environment detection (🐳 Docker / 💻 Local)
- Virtual env & Python checks
- DB connectivity hints (☁️ Cloud / 💾 Local)

### 4) Integrated Console
- Collapsible **live output** with timestamped lines
- Auto‑scroll and copy‑ready monospace text
- Perfect for quick diagnostics

### 5) Admin‑Grade Utilities
- One‑click **DB setup**
- **Docker** helpers (when available)
- **Log viewer**, **settings**, **backup/restore**
- Toast notifications & menu bar niceties

---

## 📥 Installation

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-4.0 gir1.2-adw-1
```

### Fedora
```bash
sudo dnf install python3-gobject gtk4 libadwaita
```

### Arch Linux
```bash
sudo pacman -S python-gobject gtk4 libadwaita
```

### macOS (Homebrew)
```bash
brew install pygobject3 gtk4 libadwaita
```

### Windows (MSYS2)
```bash
pacman -S mingw-w64-x86_64-python-gobject mingw-w64-x86_64-gtk4 mingw-w64-x86_64-libadwaita
```

Python dependency:
```bash
pip install PyGObject
```

---

## 🖥️ Desktop Integration
Create a desktop entry for quick launching:
```desktop
[Desktop Entry]
Name=TRMS Launcher
Comment=The Race Management Solution
Exec=/path/to/trms_launcher_gui.py
Icon=applications-games
Terminal=false
Type=Application
Categories=Sports;Database;
StartupNotify=true
```
Update cache:
```bash
update-desktop-database ~/.local/share/applications/
```

---

## ⚙️ Configuration

### Environment Variables
```bash
# Database
export USE_CLOUD_DB=true
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=trms
export DB_PASSWORD=secure_password

# Launcher
export TRMS_ENV=production
export TRMS_BASE=/path/to/trms
export TRMS_DEBUG=false
```

### Settings File (`~/.config/trms/launcher.conf`)
```ini
[General]
theme=auto
show_console_on_launch=false
auto_refresh=true
refresh_interval=5

[Database]
use_cloud=false
local_host=localhost
local_port=3306
cloud_host=db.example.com
cloud_port=3306

[Advanced]
debug_mode=false
log_level=INFO
```

---

## ⌨️ Keyboard Shortcuts
| Shortcut | Action |
|---|---|
| `Ctrl+R` | Refresh status |
| `Ctrl+Q` | Quit application |
| `Ctrl+,` | Open settings |
| `F1` | Show help |
| `F5` | Refresh |
| `Ctrl+Shift+C` | Toggle console |
| `Ctrl+L` | View logs |

---

## 🛠️ Troubleshooting

<details>
<summary><b>GTK4 not found</b></summary>

```bash
pkg-config --modversion gtk4
sudo apt install libgtk-4-1
```
</details>

<details>
<summary><b>libadwaita not available</b></summary>

```bash
sudo apt install libadwaita-1-0 gir1.2-adw-1
```
</details>

<details>
<summary><b>Permission denied</b></summary>

```bash
chmod +x trms_launcher_gui.py
ls -la /path/to/trms
```
</details>

<details>
<summary><b>No console output</b></summary>

- Toggle the “Console Output” expander  
- Ensure dependent apps exist and are executable  
- Verify shell scripts have `+x` permissions
</details>

---

## 🧩 Architecture
```
TRMS GTK4 Launcher
├── Application Detection
│   ├── Environment scanning
│   ├── Directory validation
│   └── Dependency checking
├── Launch Management
│   ├── Process spawning
│   ├── Output capture
│   └── Error handling
├── Status Monitoring
│   ├── Database connectivity
│   ├── Service health
│   └── Resource usage
└── User Interface
    ├── Main window
    ├── Dialogs
    └── Notifications
```

---

## 🧪 Screenshots
> Drop screenshots in `docs/` and link them here:
- `docs/launcher-main.png`  
- `docs/launcher-console.png`  
- `docs/launcher-settings.png`

---

## 🤝 Contributing & License
- PRs welcome — fork, branch, and open a PR with clear notes.
- Licensed under **MIT**.

---

*Crafted for race directors who want power tools — without the terminal.*
