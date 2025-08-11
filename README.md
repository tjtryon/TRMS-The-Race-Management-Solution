# 🏁 TRMS: The Race Management Solution

**Complete ecosystem for race management, registration, timing, and web interface**

## 🏗️ Architecture

```
TRMS: The Race Management Solution/
├── 📋 TRRS: The Race Registration Solution/    # Race registration management
├── ⏱️  TRTS: The Race Timing Solution/          # Race timing (from GitHub)
├── 🌐 TRWS: The Race Web Solution/             # Unified web interface
└── 🗄️  TRDS: The Race Data Solution/           # Shared data & configuration
```

## 🚀 Quick Start

1. **Setup TRMS**:
   ```bash
   chmod +x TRMS_Complete_Setup.sh
   ./TRMS_Complete_Setup.sh
   ```

2. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Launch applications**:
   ```bash
   # Use master launcher
   ./trms_launcher.sh
   
   # Or launch individual components
   ./run_trrs_console.sh    # Registration console
   ./run_trts_console.sh    # Timing console
   ```

## 📋 Components

### TRRS: The Race Registration Solution
- **Console**: `./run_trrs_console.sh`
- **GUI**: Coming soon
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
- Status visible in all applications

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

Check system status with:
```bash
./trms_launcher.sh
# Select option 6: System Status
```

## 🏃‍♂️ Example Usage

### Create a Race (TRRS Console)
1. Launch: `./run_trrs_console.sh`
2. Select: "1. Race Management"
3. Select: "1. Create New Race"
4. Fill in race details
5. Race is available to both TRRS and TRTS

### Time a Race (TRTS)
1. Launch: `./run_trts_console.sh`
2. Load race from shared database
3. Configure timing settings
4. Start race timing
5. Results saved to shared database

## 🔧 Troubleshooting

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
- If missing, manually clone: `git clone https://github.com/tjtryon/TRTS-The-Race-Timing-Solution.git "TRTS: The Race Timing Solution"`

## 🤝 Contributing

1. Work within the established directory structure
2. Use shared libraries for common functionality
3. Follow naming conventions (TRXS format)
4. Update documentation and requirements

## 📜 License

This project is open source. See individual component licenses for details.

## 🆘 Support

- Check documentation in each solution's `docs/` directory
- Review logs in `TRDS/logs/`
- Use system status check in launcher
- Report issues to respective repositories
