# 🏁 TRRS: The Race Registration Solution

**Complete race registration management system for organizing and managing race participants**

## 🎯 Purpose

TRRS handles all aspects of race registration including:
- **Race management** - Create and manage race events
- **Participant registration** - Online and offline registration
- **Payment processing** - Entry fees and payment tracking
- **Communication** - Email confirmations and updates
- **Reporting** - Registration statistics and participant lists

## 🚀 Quick Start

### Prerequisites

1. **TRDS** must be set up first (provides database and shared libraries)
2. **Python 3.8+** installed
3. **Database** configured (MySQL/MariaDB)

### Installation

```bash
# From TRMS base directory
./TRMS_Complete_Setup.sh

# Install dependencies
pip install -r requirements.txt

# Launch TRRS Console
./run_trrs_console.sh
```

## 🖥️ Console Application

The TRRS console provides a complete command-line interface for race management.

### Main Features

1. **🏁 Race Management**
   - Create new races
   - View all races
   - Edit race details
   - Delete races
   - View upcoming races

2. **👥 Participant Registration** (Coming Soon)
3. **📊 Registration Reports** (Coming Soon)
4. **💳 Payment Management** (Coming Soon)
5. **📧 Email Communications** (Coming Soon)

### Race Management Workflow

```bash
# 1. Launch TRRS Console
./run_trrs_console.sh

# 2. Select "1. Race Management"
# 3. Select "1. Create New Race"
# 4. Fill in race details
```

## 🗄️ Database Integration

TRRS uses TRDS for all database operations with automatic cloud/local failover.

## 🔌 Integration with TRMS Ecosystem

### TRTS Integration

TRRS creates races that TRTS can use for timing:

```bash
# 1. Create race in TRRS
./run_trrs_console.sh

# 2. Use race in TRTS  
./run_trts_console.sh
```

## 📋 Requirements

- **Operating System**: Linux, macOS, Windows
- **Python**: 3.8 or higher
- **Database**: MySQL 8.0+ or MariaDB 10.5+
- **Memory**: 512 MB RAM minimum

## 📜 License

See LICENSE file in this directory.

---

*TRRS is part of the TRMS ecosystem. Ensure TRDS is properly configured before using TRRS.*
