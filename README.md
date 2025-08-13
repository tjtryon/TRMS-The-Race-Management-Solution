# 🏁 TRMS: The Race Management Solution

**Complete ecosystem for race management, registration, timing, and web interface**

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/tjtryon/TRMS)
[![Python](https://img.shields.io/badge/python-3.8+-yellow)](https://www.python.org/)
[![GTK](https://img.shields.io/badge/GTK-4.0-green)](https://www.gtk.org/)
[![License](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

## 🏗️ Architecture

```
TRMS: The Race Management Solution/
├── 📋 TRRS: The Race Registration Solution/    # Race registration management
├── ⏱️  TRTS: The Race Timing Solution/          # Race timing (from GitHub)
├── 🌐 TRWS: The Race Web Solution/             # Unified web interface
└── 🗄️  TRDS: The Race Data Solution/           # Shared data & configuration
```

## 🚀 Quick Start

### Option 1: GUI Launcher (Recommended)

1. **Install GTK4 dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-4.0 gir1.2-adw-1
   
   # Fedora
   sudo dnf install python3-gobject gtk4 libadwaita
   
   # macOS
   brew install pygobject3 gtk4 libadwaita
   ```

2. **Setup TRMS**:
   ```bash
   chmod +x TRMS_Complete_Setup.sh
   ./TRMS_Complete_Setup.sh
   ```

3. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Launch the GTK4 GUI** (supports both Wayland and X11):
   ```bash
   # Auto-detect display server (recommended)
   ./trms_launcher_gui.py
   
   # Force Wayland
   GDK_BACKEND=wayland ./trms_launcher_gui.py
   
   # Force X11 (fallback)
   GDK_BACKEND=x11 ./trms_launcher_gui.py
   ```

### Option 2: Console Launcher

```bash
# Use console-based launcher
./trms_launcher.sh

# Or launch individual components
./run_trrs_console.sh    # Registration console
./run_trts_console.sh    # Timing console
```

## 🖼️ Interfaces

### GTK4 GUI Launcher (NEW!)
- **Modern graphical interface** for managing all TRMS components
- **Real-time status monitoring** of all services
- **Integrated console output** for debugging
- **One-click launching** of all applications
- See [GTK4_GUI_README.md](GTK4_GUI_README.md) for details

### Console Applications
- **Text-based interfaces** for terminal users
- **Scriptable operations** for automation
- **Lightweight** and fast

## 📋 Components

### TRRS: The Race Registration Solution
- **Console**: `./run_trrs_console.sh`
- **GUI**: Via GTK4 launcher
- **Features**: Race management, participant registration, payment processing

### TRTS: The Race Timing Solution
- **Console**: `./run_trts_console.sh`
- **GUI**: Available (from GitHub repository)
- **Features**: Race timing, chip timing, results processing

### TRWS: The Race Web Solution
- **Status**: Coming soon
- **Features**: Unified web interface for all components

### TRDS: The Race Data Solution
- **Shared libraries** for database, configuration, and models
- **Cloud/local database** support with automatic failover
- **Centralized logging** and configuration management

## 🗄️ Database Configuration

TRMS supports both **cloud** and **local** databases with automatic failover:

### Environment Variables
```bash
# Local database (default)
export DB_HOST=localhost
export DB_PASSWORD=your_password

# Cloud database (optional)
export CLOUD_DB_HOST=your.cloud.host
export USE_CLOUD_DB=true

# General settings
export TRMS_ENV=development
```

### Automatic Failover
- Attempts cloud connection first (if configured)
- Falls back to local database automatically
- Status visible in all applications and GUI launcher

## 🛠️ Development

### Directory Structure
- Each solution is self-contained
- Shared libraries in `TRDS/libraries/`
- Centralized configuration in `TRDS/config/`
- Unified logging in `TRDS/logs/`

### Adding New Features
1. Update models in `TRDS/libraries/models/`
2. Add database migrations to `TRDS/sql/migrations/`
3. Implement features in respective solutions
4. Update configuration if needed

## 📊 System Status

### Via GUI Launcher
- Real-time status dashboard
- Visual indicators for all components
- Database connection monitoring
- Environment detection

### Via Console
```bash
./trms_launcher.sh
# Select option 6: System Status
```

## 🏃‍♂️ Example Usage

### Create a Race (GUI Method)
1. Launch GTK4 GUI: `./trms_launcher_gui.py`
2. Click "Console Application" under TRRS card
3. Select "Race Management" → "Create New Race"
4. Fill in race details
5. Race is available to both TRRS and TRTS

### Create a Race (Console Method)
1. Launch: `./run_trrs_console.sh`
2. Select: "1. Race Management"
3. Select: "1. Create New Race"
4. Fill in race details
5. Race is available to both TRRS and TRTS

### Time a Race (TRTS)
1. Launch from GUI or use: `./run_trts_console.sh`
2. Load race from shared database
3. Configure timing settings
4. Start race timing
5. Results saved to shared database

## 🎨 User Interfaces

| Interface | Type | Description | Best For |
|-----------|------|-------------|----------|
| **GTK4 Launcher** | GUI | Modern graphical launcher | Desktop users, visual management |
| **Console Launcher** | TUI | Text-based menu system | SSH sessions, automation |
| **TRRS Console** | CLI | Registration management | Data entry, batch operations |
| **TRTS GUI** | GUI | Timing interface | Race day operations |
| **TRTS Console** | CLI | Timing management | Remote timing, scripting |

## 🔧 Troubleshooting

### GTK4 GUI Issues
- Ensure GTK4 and libadwaita are installed
- Check PyGObject installation: `python3 -c "import gi"`
- **Wayland** (modern Linux): Check `echo $WAYLAND_DISPLAY`
- **X11** (legacy/fallback): Set `export DISPLAY=:0` for SSH
- Force backend if needed: `GDK_BACKEND=wayland` or `GDK_BACKEND=x11`
- See [GTK4_GUI_README.md](GTK4_GUI_README.md) for more

### Database Connection Issues
- Check environment variables
- Verify database is running
- Check network connectivity for cloud databases
- Review logs in `TRDS/logs/`

### Python Path Issues
- Ensure you're in TRMS base directory
- Check virtual environment activation
- Verify TRMS_BASE environment variable

### Missing TRTS
- TRTS is cloned from GitHub automatically
- If missing, manually clone: 
  ```bash
  git clone https://github.com/tjtryon/TRTS-The-Race-Timing-Solution.git \
    "TRTS: The Race Timing Solution"
  ```

## 📦 System Requirements

### Minimum
- Python 3.8+
- 2GB RAM
- 100MB disk space
- MariaDB/MySQL 5.7+

### Recommended (for GUI)
- Python 3.10+
- 4GB RAM
- GTK 4.6+
- libadwaita 1.2+
- Wayland compositor (GNOME 40+, KDE Plasma 5.24+) or X11
- Hardware acceleration

## 🤝 Contributing

1. Work within the established directory structure
2. Use shared libraries for common functionality
3. Follow naming conventions (TRXS format)
4. Update documentation and requirements
5. Test with both GUI and console interfaces

## 📚 Documentation

- [GTK4 GUI Documentation](GTK4_GUI_README.md)
- Component docs in each solution's `docs/` directory
- API documentation in `TRDS/docs/api/`
- Database schema in `TRDS/sql/`

## 📜 License

This project is open source under the MIT License. See [LICENSE](LICENSE) file for details.

## 🆘 Support

- **GUI Issues**: See [GTK4_GUI_README.md](GTK4_GUI_README.md)
- **Documentation**: Check each solution's `docs/` directory
- **Logs**: Review logs in `TRDS/logs/`
- **System Status**: Use GUI launcher or console menu
- **GitHub Issues**: Report bugs and feature requests

## 🎉 Acknowledgments

- **TRTS**: [TJ Tryon's Race Timing Solution](https://github.com/tjtryon/TRTS-The-Race-Timing-Solution)
- **GTK Team**: For the GTK4 framework
- **GNOME Project**: For libadwaita
- **Community**: For feedback and contributions

---

*TRMS provides a complete, professional solution for race management with both modern GUI and efficient console interfaces.*