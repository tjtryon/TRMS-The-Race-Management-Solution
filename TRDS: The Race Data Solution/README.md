# 🗄️ TRDS: The Race Data Solution

**Shared data management, configuration, and libraries for the TRMS ecosystem**

## 🎯 Purpose

TRDS serves as the foundation for all TRMS components, providing:
- **Unified database management** with cloud/local failover
- **Shared libraries** and models used by TRRS, TRTS, and TRWS
- **Centralized configuration** management
- **Logging and monitoring** infrastructure
- **Database schemas** and migration tools

## 🚀 Quick Start

### Installation

TRDS is automatically set up when you run the TRMS setup script:

```bash
# From TRMS base directory
./TRMS_Complete_Setup.sh
```

### Manual Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Set up database
cd scripts/
./setup_database.sh

# Test connection
python3 -c "from libraries.database.connection import db_manager; print('Connected:', db_manager.test_connection())"
```

## 🔌 Database Configuration

### Cloud/Local Database Support

TRDS supports automatic failover between cloud and local databases:

```bash
# Environment variables
export USE_CLOUD_DB=true                    # Enable cloud database
export CLOUD_DB_HOST=your.cloud.host       # Cloud database host
export DB_HOST=localhost                    # Local database host
export DB_PASSWORD=your_password            # Database password
```

## 📚 Libraries

### Database Connection

```python
from libraries.database.connection import db_manager

# Test connection
connected = db_manager.test_connection()

# Execute query
results = db_manager.execute_query("SELECT * FROM races")

# Get connection status
status = db_manager.get_status()
```

### Race Models

```python
from libraries.models.race import Race, race_manager
from datetime import date

# Create a race
race = Race(
    race_name="Spring 5K",
    race_date=date(2024, 4, 15),
    race_type="road_race",
    entry_fee=25.00
)

race_id = race_manager.create_race(race)
```

## 🔧 Troubleshooting

**Database Connection Failed**
```bash
# Check database status
systemctl status mysql

# Test manual connection
mysql -h $DB_HOST -u trms -p
```

## 📋 Requirements

- Python 3.8+
- MySQL/MariaDB 8.0+
- Required Python packages (see requirements.txt)

## 📜 License

See LICENSE file in this directory.

---

*TRDS provides the foundation for the entire TRMS ecosystem.*
