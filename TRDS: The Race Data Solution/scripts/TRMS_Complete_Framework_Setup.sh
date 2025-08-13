#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TEMS: The Event Management Solution - Complete Setup Script
# ═══════════════════════════════════════════════════════════════════════════════
# 
# 📝 DESCRIPTION:
#     Unified setup script for the complete Event Management Solution ecosystem
#     including TERS (Registration), TRTS (Timing), TRWS (Web), and TRDS (Data)
#
# 🏗️ ARCHITECTURE:
#     TEMS: The Event Management Solution/
#     ├── TERS: The Event Registration Solution/
#     ├── TRTS: The Race Timing Solution/
#     ├── TRWS: The Race Web Solution/
#     └── TRDS: The Race Data Solution/
#
# 🚀 USAGE:
#     Run from TEMS directory: ./scripts/TEMS_Setup_Script.sh
#     Or from anywhere: bash /path/to/TEMS_Setup_Script.sh
#
# 👤 AUTHOR: TEMS Development Team
# 📅 CREATED: 2024
# 🏷️ VERSION: 1.0.0
# ═══════════════════════════════════════════════════════════════════════════════

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 AUTO-DETECT AND SET UP DIRECTORY STRUCTURE
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🏁 TEMS: The Event Management Solution - Unified Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to find or create TEMS base directory
find_or_create_tems_base() {
    local current_dir=$(pwd)
    local script_dir=$(dirname "$(readlink -f "$0")")
    
    # Check if we're already in TEMS or a subdirectory
    if [[ "$current_dir" == *"TEMS: The Event Management Solution"* ]]; then
        # Navigate up to TEMS root
        while [[ "$(basename "$current_dir")" != "TEMS: The Event Management Solution" ]] && [ "$current_dir" != "/" ]; do
            current_dir=$(dirname "$current_dir")
        done
        echo "$current_dir"
    elif [[ -d "$current_dir/TEMS: The Event Management Solution" ]]; then
        echo "$current_dir/TEMS: The Event Management Solution"
    else
        # Create TEMS in current directory
        echo "$current_dir/TEMS: The Event Management Solution"
    fi
}

# Set up base directories
TEMS_BASE=$(find_or_create_tems_base)
echo -e "${BLUE}📁 Setting up TEMS base directory at: ${WHITE}$TEMS_BASE${NC}"

# Create TEMS base if it doesn't exist
if [ ! -d "$TEMS_BASE" ]; then
    echo -e "${YELLOW}📦 Creating TEMS base directory structure...${NC}"
    mkdir -p "$TEMS_BASE"
fi

cd "$TEMS_BASE"

# Define all solution directories with full names
TERS_DIR="$TEMS_BASE/TERS: The Event Registration Solution"
TRTS_DIR="$TEMS_BASE/TRTS: The Race Timing Solution"
TRWS_DIR="$TEMS_BASE/TRWS: The Race Web Solution"
TRDS_DIR="$TEMS_BASE/TRDS: The Race Data Solution"

# Export for use in Python scripts
export TEMS_BASE
export TERS_DIR
export TRTS_DIR
export TRWS_DIR
export TRDS_DIR

echo -e "${GREEN}✅ Directory variables set:${NC}"
echo -e "   ${WHITE}TEMS_BASE:${NC} $TEMS_BASE"
echo -e "   ${WHITE}TERS_DIR:${NC} $TERS_DIR"
echo -e "   ${WHITE}TRTS_DIR:${NC} $TRTS_DIR"
echo -e "   ${WHITE}TRWS_DIR:${NC} $TRWS_DIR"
echo -e "   ${WHITE}TRDS_DIR:${NC} $TRDS_DIR"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 CREATE COMPLETE DIRECTORY STRUCTURE
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📁 Creating complete TEMS directory structure...${NC}"

# Create TERS directories
mkdir -p "$TERS_DIR"/{console,gui,scripts,docs,tests/{unit,integration}}

# Create TRTS directories (if not exists, don't modify existing)
if [ ! -d "$TRTS_DIR" ]; then
    mkdir -p "$TRTS_DIR"/{console,gui,scripts,docs}
fi

# Create TRWS directories (unified web solution)
mkdir -p "$TRWS_DIR"/web/{templates/{base,ters,trts,shared},static/{css,js,images,fonts}}
mkdir -p "$TRWS_DIR"/nginx/{conf.d,ssl}
mkdir -p "$TRWS_DIR"/docker
mkdir -p "$TRWS_DIR"/api/{ters,trts,shared}

# Create TRDS directories (data solution)
mkdir -p "$TRDS_DIR"/databases/{mysql,backups}
mkdir -p "$TRDS_DIR"/logs/{ters,trts,web,system}
mkdir -p "$TRDS_DIR"/sql/{init,migrations,stored_procedures}
mkdir -p "$TRDS_DIR"/libraries/{database,utils,models,api}
mkdir -p "$TRDS_DIR"/config/{development,staging,production,docker}
mkdir -p "$TRDS_DIR"/backups/{daily,weekly,monthly}

echo -e "${GREEN}✅ Directory structure created successfully!${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 📚 CREATE SHARED LIBRARIES IN TRDS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📚 Creating shared libraries in TRDS: The Race Data Solution...${NC}"

# Create __init__.py files for Python packages
touch "$TRDS_DIR/libraries/__init__.py"
touch "$TRDS_DIR/libraries/database/__init__.py"
touch "$TRDS_DIR/libraries/utils/__init__.py"
touch "$TRDS_DIR/libraries/models/__init__.py"
touch "$TRDS_DIR/libraries/api/__init__.py"

# Create path resolver utility
cat > "$TRDS_DIR/libraries/utils/paths.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🗺️ TEMS Path Resolution Utility
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Automatic path resolution for TEMS ecosystem. Finds directories regardless
    of where scripts are run from.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
from pathlib import Path
from typing import Optional

class TEMSPaths:
    """Path resolver for TEMS ecosystem."""
    
    @staticmethod
    def find_tems_base() -> Path:
        """Find the TEMS base directory from any location."""
        # Check environment variable first
        if 'TEMS_BASE' in os.environ:
            return Path(os.environ['TEMS_BASE'])
        
        # Start from current file location
        current = Path(__file__).resolve()
        
        # Navigate up until we find TEMS
        while current != current.parent:
            if 'TEMS: The Event Management Solution' in current.name:
                return current
            # Check all parents
            for parent in current.parents:
                if 'TEMS: The Event Management Solution' in parent.name:
                    return parent
            current = current.parent
        
        # Try from current working directory
        cwd = Path.cwd()
        if 'TEMS: The Event Management Solution' in str(cwd):
            parts = str(cwd).split('TEMS: The Event Management Solution')
            return Path(parts[0]) / 'TEMS: The Event Management Solution'
        
        # Default fallback
        return Path.cwd() / 'TEMS: The Event Management Solution'
    
    def __init__(self):
        """Initialize paths for TEMS ecosystem."""
        self.TEMS_BASE = self.find_tems_base()
        self.TERS_DIR = self.TEMS_BASE / 'TERS: The Event Registration Solution'
        self.TRTS_DIR = self.TEMS_BASE / 'TRTS: The Race Timing Solution'
        self.TRWS_DIR = self.TEMS_BASE / 'TRWS: The Race Web Solution'
        self.TRDS_DIR = self.TEMS_BASE / 'TRDS: The Race Data Solution'
        
        # Add libraries to Python path
        lib_path = str(self.TRDS_DIR / 'libraries')
        if lib_path not in sys.path:
            sys.path.insert(0, lib_path)
    
    def get_log_dir(self, solution: str = 'system') -> Path:
        """Get log directory for a specific solution."""
        return self.TRDS_DIR / 'logs' / solution
    
    def get_config_dir(self, environment: str = 'development') -> Path:
        """Get configuration directory for environment."""
        return self.TRDS_DIR / 'config' / environment
    
    def get_backup_dir(self, frequency: str = 'daily') -> Path:
        """Get backup directory by frequency."""
        return self.TRDS_DIR / 'backups' / frequency

# Global paths instance
paths = TEMSPaths()

# Export commonly used paths
TEMS_BASE = paths.TEMS_BASE
TERS_DIR = paths.TERS_DIR
TRTS_DIR = paths.TRTS_DIR
TRWS_DIR = paths.TRWS_DIR
TRDS_DIR = paths.TRDS_DIR
EOF

# Create configuration management module
cat > "$TRDS_DIR/libraries/utils/config.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
⚙️ TEMS Unified Configuration Management
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Centralized configuration for all TEMS solutions with automatic cloud/local
    database switching and Docker support.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import os
import yaml
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field
from pathlib import Path

# Import path resolver
from .paths import paths, TEMS_BASE, TRDS_DIR

class DatabaseConfig(BaseModel):
    """Database configuration with cloud/local support."""
    # Local database settings
    local_host: str = Field(default="localhost", description="Local database host")
    local_port: int = Field(default=3306, description="Local database port")
    
    # Cloud database settings
    cloud_host: Optional[str] = Field(default=None, description="Cloud database host")
    cloud_port: int = Field(default=3306, description="Cloud database port")
    
    # Shared settings
    database: str = Field(default="tems_db", description="Database name")
    user: str = Field(default="tems", description="Database user")
    password: str = Field(default="", description="Database password")
    
    # Control settings
    use_cloud: bool = Field(default=False, description="Use cloud database")
    auto_failover: bool = Field(default=True, description="Auto failover to local")
    
    @property
    def host(self) -> str:
        """Get active host based on cloud/local setting."""
        return self.cloud_host if self.use_cloud and self.cloud_host else self.local_host
    
    @property
    def port(self) -> int:
        """Get active port based on cloud/local setting."""
        return self.cloud_port if self.use_cloud and self.cloud_host else self.local_port
    
    def get_connection_string(self) -> str:
        """Get database connection string."""
        return f"mysql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"

class WebConfig(BaseModel):
    """Web server configuration for TRWS."""
    host: str = Field(default="0.0.0.0", description="Web server host")
    port: int = Field(default=8000, description="Web server port")
    workers: int = Field(default=4, description="Number of workers")
    debug: bool = Field(default=False, description="Debug mode")
    
    # Docker settings
    docker_host: str = Field(default="trws-web", description="Docker service name")
    docker_port: int = Field(default=8000, description="Docker internal port")
    
    # API endpoints
    ters_api_url: str = Field(default="/api/ters", description="TERS API endpoint")
    trts_api_url: str = Field(default="/api/trts", description="TRTS API endpoint")

class DockerConfig(BaseModel):
    """Docker deployment configuration."""
    compose_file: str = Field(default="docker-compose.yml", description="Compose file")
    network_name: str = Field(default="tems-network", description="Docker network")
    
    # Service names
    db_service: str = Field(default="tems-db", description="Database service")
    web_service: str = Field(default="tems-web", description="Web service")
    nginx_service: str = Field(default="tems-nginx", description="Nginx service")
    
    # Volumes
    use_volumes: bool = Field(default=True, description="Use Docker volumes")
    
class LoggingConfig(BaseModel):
    """Logging configuration."""
    level: str = Field(default="INFO", description="Log level")
    format: str = Field(default="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    
    # Log rotation
    max_bytes: int = Field(default=10485760, description="Max log file size (10MB)")
    backup_count: int = Field(default=5, description="Number of backup files")

class TEMSConfig(BaseModel):
    """Master configuration for TEMS ecosystem."""
    # Environment
    environment: str = Field(default="development", description="Environment name")
    version: str = Field(default="1.0.0", description="TEMS version")
    
    # Component configurations
    database: DatabaseConfig = Field(default_factory=DatabaseConfig)
    web: WebConfig = Field(default_factory=WebConfig)
    docker: DockerConfig = Field(default_factory=DockerConfig)
    logging: LoggingConfig = Field(default_factory=LoggingConfig)
    
    # Paths (auto-populated)
    tems_base: Path = Field(default_factory=lambda: TEMS_BASE)
    trds_dir: Path = Field(default_factory=lambda: TRDS_DIR)
    
    def save(self, environment: Optional[str] = None):
        """Save configuration to file."""
        env = environment or self.environment
        config_file = self.trds_dir / 'config' / f'{env}.yaml'
        config_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(config_file, 'w') as f:
            yaml.dump(self.dict(), f, default_flow_style=False)

def load_config(environment: Optional[str] = None) -> TEMSConfig:
    """Load configuration from file and environment variables."""
    # Determine environment
    if not environment:
        environment = os.getenv('TEMS_ENV', 'development')
    
    # Load from config file
    config_file = TRDS_DIR / 'config' / f'{environment}.yaml'
    
    if config_file.exists():
        with open(config_file, 'r') as f:
            config_data = yaml.safe_load(f) or {}
        config = TEMSConfig(**config_data)
    else:
        config = TEMSConfig(environment=environment)
    
    # Override with environment variables
    if 'DB_HOST' in os.environ:
        config.database.local_host = os.environ['DB_HOST']
    if 'CLOUD_DB_HOST' in os.environ:
        config.database.cloud_host = os.environ['CLOUD_DB_HOST']
    if 'DB_PASSWORD' in os.environ:
        config.database.password = os.environ['DB_PASSWORD']
    if 'USE_CLOUD_DB' in os.environ:
        config.database.use_cloud = os.environ['USE_CLOUD_DB'].lower() == 'true'
    
    return config

# Global configuration instance
config = load_config()
EOF

# Create database connection module
cat > "$TRDS_DIR/libraries/database/connection.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🔌 TEMS Unified Database Connection Management
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Database connection management with automatic cloud/local switching,
    connection pooling, and failover support.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import mysql.connector
from mysql.connector import Error, pooling
import logging
from typing import Optional, Dict, Any, List
from contextlib import contextmanager
import time

from ..utils.config import config
from ..utils.paths import paths

# Set up logging
logger = logging.getLogger(__name__)

class DatabaseManager:
    """Unified database manager with cloud/local support."""
    
    def __init__(self, config_override: Optional[Dict] = None):
        """Initialize database manager."""
        self.config = config.database
        if config_override:
            for key, value in config_override.items():
                setattr(self.config, key, value)
        
        self.pool = None
        self.is_cloud_connected = False
        self._initialize_pool()
    
    def _initialize_pool(self):
        """Initialize connection pool with failover support."""
        # Try cloud connection first if configured
        if self.config.use_cloud and self.config.cloud_host:
            if self._try_cloud_connection():
                return
        
        # Fall back to local connection
        self._try_local_connection()
    
    def _try_cloud_connection(self) -> bool:
        """Attempt to connect to cloud database."""
        try:
            logger.info(f"Attempting cloud database connection to {self.config.cloud_host}")
            
            pool_config = {
                'pool_name': 'tems_cloud_pool',
                'pool_size': 10,
                'pool_reset_session': True,
                'host': self.config.cloud_host,
                'port': self.config.cloud_port,
                'user': self.config.user,
                'password': self.config.password,
                'database': self.config.database,
                'raise_on_warnings': False,
                'connection_timeout': 10
            }
            
            self.pool = pooling.MySQLConnectionPool(**pool_config)
            
            # Test connection
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                cursor.close()
            
            self.is_cloud_connected = True
            logger.info("✅ Connected to CLOUD database successfully")
            return True
            
        except Error as e:
            logger.warning(f"Cloud database connection failed: {e}")
            if self.config.auto_failover:
                logger.info("Attempting failover to local database...")
            return False
    
    def _try_local_connection(self) -> bool:
        """Connect to local database."""
        try:
            logger.info(f"Connecting to local database at {self.config.local_host}")
            
            pool_config = {
                'pool_name': 'tems_local_pool',
                'pool_size': 5,
                'pool_reset_session': True,
                'host': self.config.local_host,
                'port': self.config.local_port,
                'user': self.config.user,
                'password': self.config.password,
                'database': self.config.database,
                'raise_on_warnings': False
            }
            
            self.pool = pooling.MySQLConnectionPool(**pool_config)
            self.is_cloud_connected = False
            logger.info("✅ Connected to LOCAL database successfully")
            return True
            
        except Error as e:
            logger.error(f"Local database connection failed: {e}")
            raise
    
    @contextmanager
    def get_connection(self):
        """Get database connection from pool."""
        connection = None
        try:
            connection = self.pool.get_connection()
            yield connection
        except Error as e:
            logger.error(f"Database connection error: {e}")
            # Try to reconnect if pool is exhausted
            if "Failed getting connection" in str(e):
                time.sleep(1)
                self._initialize_pool()
                connection = self.pool.get_connection()
                yield connection
            else:
                raise
        finally:
            if connection and connection.is_connected():
                connection.close()
    
    def test_connection(self) -> bool:
        """Test database connectivity."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                result = cursor.fetchone()
                cursor.close()
                return result is not None
        except Exception as e:
            logger.error(f"Connection test failed: {e}")
            return False
    
    def execute_query(self, query: str, params: Optional[tuple] = None) -> List[Dict]:
        """Execute SELECT query."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query, params or ())
                results = cursor.fetchall()
                cursor.close()
                return results
        except Error as e:
            logger.error(f"Query failed: {e}")
            raise
    
    def execute_update(self, query: str, params: Optional[tuple] = None) -> int:
        """Execute INSERT/UPDATE/DELETE query."""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params or ())
                conn.commit()
                affected = cursor.rowcount
                cursor.close()
                return affected
        except Error as e:
            logger.error(f"Update failed: {e}")
            raise
    
    def get_status(self) -> Dict[str, Any]:
        """Get connection status information."""
        return {
            'connected': self.test_connection(),
            'is_cloud': self.is_cloud_connected,
            'host': self.config.cloud_host if self.is_cloud_connected else self.config.local_host,
            'database': self.config.database,
            'pool_size': self.pool.pool_size if self.pool else 0
        }

# Global database manager
db_manager = DatabaseManager()
EOF

# Create database models
cat > "$TRDS_DIR/libraries/models/race.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 Race Models for TEMS
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Shared race models used by both TERS and TRTS.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

from typing import Optional, List
from datetime import datetime, date, time
from pydantic import BaseModel, Field, validator
from ..database.connection import db_manager

class Race(BaseModel):
    """Race model for TEMS ecosystem."""
    race_id: Optional[int] = Field(None, description="Race ID")
    race_name: str = Field(..., description="Race name")
    race_description: Optional[str] = Field(None, description="Description")
    race_date: date = Field(..., description="Race date")
    race_time: Optional[time] = Field(None, description="Start time")
    race_venue: Optional[str] = Field(None, description="Venue")
    race_type: str = Field(default="road_race", description="Race type")
    race_distances: Optional[str] = Field(None, description="Distances")
    course_link: Optional[str] = Field(None, description="Course link")
    registration_link: Optional[str] = Field(None, description="Registration link")
    created_at: Optional[datetime] = Field(None, description="Created timestamp")
    updated_at: Optional[datetime] = Field(None, description="Updated timestamp")
    
    # TERS specific fields
    registration_open: bool = Field(default=True, description="Registration open")
    registration_limit: Optional[int] = Field(None, description="Max participants")
    entry_fee: Optional[float] = Field(None, description="Entry fee")
    
    # TRTS specific fields
    timing_method: Optional[str] = Field(None, description="Timing method")
    chip_timing: bool = Field(default=False, description="Use chip timing")
    
    @validator('race_type')
    def validate_race_type(cls, v):
        """Validate race type."""
        valid_types = ['road_race', 'cross_country', 'track', 'trail', 'virtual', 'triathlon']
        if v not in valid_types:
            raise ValueError(f"Race type must be one of {valid_types}")
        return v

class RaceManager:
    """Manager for race database operations."""
    
    def __init__(self):
        """Initialize race manager."""
        self.table_name = "races"
    
    def create_race(self, race: Race) -> Optional[int]:
        """Create new race."""
        query = f"""
            INSERT INTO {self.table_name} 
            (race_name, race_description, race_date, race_time, race_venue,
             race_type, race_distances, course_link, registration_link,
             registration_open, registration_limit, entry_fee,
             timing_method, chip_timing)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        params = (
            race.race_name, race.race_description, race.race_date, race.race_time,
            race.race_venue, race.race_type, race.race_distances,
            race.course_link, race.registration_link,
            race.registration_open, race.registration_limit, race.entry_fee,
            race.timing_method, race.chip_timing
        )
        
        try:
            result = db_manager.execute_update(query, params)
            return result
        except Exception as e:
            print(f"Error creating race: {e}")
            return None
    
    def get_all_races(self) -> List[Race]:
        """Get all races."""
        query = f"SELECT * FROM {self.table_name} ORDER BY race_date DESC"
        
        try:
            results = db_manager.execute_query(query)
            return [Race(**row) for row in results]
        except Exception as e:
            print(f"Error fetching races: {e}")
            return []
    
    def get_race_by_id(self, race_id: int) -> Optional[Race]:
        """Get race by ID."""
        query = f"SELECT * FROM {self.table_name} WHERE race_id = %s"
        
        try:
            results = db_manager.execute_query(query, (race_id,))
            if results:
                return Race(**results[0])
            return None
        except Exception as e:
            print(f"Error fetching race: {e}")
            return None
    
    def update_race(self, race_id: int, race: Race) -> bool:
        """Update existing race."""
        query = f"""
            UPDATE {self.table_name}
            SET race_name = %s, race_description = %s, race_date = %s,
                race_time = %s, race_venue = %s, race_type = %s,
                race_distances = %s, course_link = %s, registration_link = %s,
                registration_open = %s, registration_limit = %s, entry_fee = %s,
                timing_method = %s, chip_timing = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE race_id = %s
        """
        
        params = (
            race.race_name, race.race_description, race.race_date, race.race_time,
            race.race_venue, race.race_type, race.race_distances,
            race.course_link, race.registration_link,
            race.registration_open, race.registration_limit, race.entry_fee,
            race.timing_method, race.chip_timing,
            race_id
        )
        
        try:
            result = db_manager.execute_update(query, params)
            return result > 0
        except Exception as e:
            print(f"Error updating race: {e}")
            return False
    
    def delete_race(self, race_id: int) -> bool:
        """Delete race."""
        query = f"DELETE FROM {self.table_name} WHERE race_id = %s"
        
        try:
            result = db_manager.execute_update(query, (race_id,))
            return result > 0
        except Exception as e:
            print(f"Error deleting race: {e}")
            return False
    
    def get_upcoming_races(self) -> List[Race]:
        """Get upcoming races."""
        query = f"""
            SELECT * FROM {self.table_name} 
            WHERE race_date >= CURDATE() 
            ORDER BY race_date ASC
        """
        
        try:
            results = db_manager.execute_query(query)
            return [Race(**row) for row in resultsRetryTTContinueEditTTUnder the TRMS: The Race Management Solution directory, create links or bash shells to run TERS: The Event Registration Solution/console/race_registration_console.py and The Event Registration Solution/gui/race_registration_gui.py and TRTS: The Race Timing Solution/console/race_timing_console.py and TRTS: The Race Timing Solution/gui/race_timing_gui.py.You will need to source activate a virtual Python environment if it is not in a docker.  If you are in docker, python should work fine without the layer of an extra python virtual environmentEditI'll continue the setup script and add convenient launcher scripts in the TEMS base directory for running all the applications. These scripts will handle virtual environment activation when needed and proper path setup.
bash# Continue from where we left off...
        except Exception as e:
            print(f"Error fetching upcoming races: {e}")
            return []

# Global race manager
race_manager = RaceManager()
EOF

echo -e "${GREEN}✅ Shared libraries created in TRDS!${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 🖥️ CREATE TERS CONSOLE APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🖥️ Creating TERS console application...${NC}"

cat > "$TERS_DIR/console/race_registration_console.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 TERS: The Event Registration Solution - Console Application
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Console application for race registration management. Part of the TEMS
    ecosystem, working alongside TRTS for complete race management.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import sys
import os
from pathlib import Path
from datetime import datetime, date, time
import logging

# Find TEMS base directory and add libraries to path
def find_tems_base():
    """Find TEMS base directory from current location."""
    current = Path(__file__).resolve()
    while current != current.parent:
        for parent in current.parents:
            if 'TEMS: The Event Management Solution' in parent.name:
                return parent
        current = current.parent
    return Path(os.environ.get('TEMS_BASE', Path.cwd()))

TEMS_BASE = find_tems_base()
TRDS_DIR = TEMS_BASE / 'TRDS: The Race Data Solution'

# Add TRDS libraries to Python path
sys.path.insert(0, str(TRDS_DIR / 'libraries'))

# Import from shared libraries
from models.race import Race, race_manager
from database.connection import db_manager
from utils.config import config
from utils.paths import paths

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(paths.get_log_dir('ters') / 'console.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TERSConsole:
    """Main console application for TERS."""
    
    def __init__(self):
        """Initialize the console application."""
        self.running = False
        self.db_status = db_manager.get_status()
        logger.info(f"TERS Console initialized - Database: {'CLOUD' if self.db_status['is_cloud'] else 'LOCAL'}")
    
    def start(self):
        """Start the console application."""
        try:
            logger.info("Starting TERS Console Application")
            
            # Test database connection
            if not db_manager.test_connection():
                print("❌ Error: Cannot connect to database!")
                print(f"🔧 Attempted connection to: {self.db_status['host']}")
                return
            
            self.show_banner()
            self.running = True
            self.main_loop()
            
        except KeyboardInterrupt:
            print("\n\n🛑 Application interrupted by user")
        except Exception as e:
            print(f"\n❌ Application error: {e}")
            logger.error(f"Application error: {e}")
        finally:
            self.cleanup()
    
    def show_banner(self):
        """Display application banner."""
        db_type = "☁️ CLOUD" if self.db_status['is_cloud'] else "💾 LOCAL"
        
        print("\n" + "="*70)
        print("   🏁 TERS: The Event Registration Solution")
        print("   📋 Console Management Interface v1.0.0")
        print(f"   🔗 Database: {db_type} - {self.db_status['host']}")
        print("   🏃 Ready to manage race registrations!")
        print("="*70)
    
    def main_loop(self):
        """Main application loop."""
        while self.running:
            try:
                self.show_main_menu()
                choice = input("\n🎯 Select option: ").strip()
                self.handle_menu_choice(choice)
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye!")
                self.running = False
            except Exception as e:
                logger.error(f"Menu error: {e}")
                print(f"\n❌ Error: {e}")
    
    def show_main_menu(self):
        """Display main menu."""
        print("\n" + "─"*50)
        print("📋 MAIN MENU")
        print("─"*50)
        print("1. 🏁 Race Management")
        print("2. 👥 Participant Registration")
        print("3. 📊 Registration Reports")
        print("4. 💳 Payment Management")
        print("5. 📧 Email Communications")
        print("6. ⚙️  Settings")
        print("0. 👋 Exit")
    
    def handle_menu_choice(self, choice):
        """Handle menu selection."""
        if choice == '1':
            self.race_management_menu()
        elif choice == '2':
            print("👥 Participant registration - Coming soon!")
        elif choice == '3':
            print("📊 Registration reports - Coming soon!")
        elif choice == '4':
            print("💳 Payment management - Coming soon!")
        elif choice == '5':
            print("📧 Email communications - Coming soon!")
        elif choice == '6':
            self.settings_menu()
        elif choice == '0':
            self.running = False
            print("\n👋 Thank you for using TERS!")
        else:
            print("❌ Invalid option")
    
    def race_management_menu(self):
        """Race management submenu."""
        while True:
            print("\n" + "─"*40)
            print("🏁 RACE MANAGEMENT")
            print("─"*40)
            print("1. ➕ Create New Race")
            print("2. 📋 View All Races")
            print("3. ✏️  Edit Race")
            print("4. ❌ Delete Race")
            print("5. 📅 Upcoming Races")
            print("0. ⬅️  Back")
            
            choice = input("\n🎯 Select option: ").strip()
            
            if choice == '1':
                self.create_race()
            elif choice == '2':
                self.view_all_races()
            elif choice == '3':
                self.edit_race()
            elif choice == '4':
                self.delete_race()
            elif choice == '5':
                self.view_upcoming_races()
            elif choice == '0':
                break
            else:
                print("❌ Invalid option")
    
    def create_race(self):
        """Create a new race."""
        print("\n➕ CREATE NEW RACE")
        print("="*40)
        
        try:
            race_data = {}
            race_data['race_name'] = input("Race Name: ").strip()
            race_data['race_description'] = input("Description: ").strip()
            race_data['race_date'] = datetime.strptime(
                input("Date (YYYY-MM-DD): ").strip(), '%Y-%m-%d'
            ).date()
            
            time_input = input("Time (HH:MM) or Enter to skip: ").strip()
            if time_input:
                race_data['race_time'] = datetime.strptime(time_input, '%H:%M').time()
            
            race_data['race_venue'] = input("Venue: ").strip()
            race_data['race_type'] = input("Type (road_race/cross_country): ").strip()
            race_data['race_distances'] = input("Distances: ").strip()
            race_data['registration_limit'] = int(input("Registration Limit (0 for unlimited): ") or 0)
            race_data['entry_fee'] = float(input("Entry Fee: $") or 0)
            
            race = Race(**race_data)
            race_id = race_manager.create_race(race)
            
            if race_id:
                print(f"\n✅ Race created successfully! ID: {race_id}")
            else:
                print("\n❌ Failed to create race")
                
        except Exception as e:
            print(f"\n❌ Error: {e}")
    
    def view_all_races(self):
        """View all races."""
        races = race_manager.get_all_races()
        
        if not races:
            print("\n📭 No races found")
            return
        
        print("\n📋 ALL RACES")
        print("="*80)
        print(f"{'ID':<5} {'Name':<30} {'Date':<12} {'Venue':<20} {'Type':<10}")
        print("-"*80)
        
        for race in races:
            print(f"{race.race_id:<5} {race.race_name[:28]:<30} "
                  f"{race.race_date:<12} {(race.race_venue or 'TBD')[:18]:<20} "
                  f"{race.race_type:<10}")
    
    def view_upcoming_races(self):
        """View upcoming races."""
        races = race_manager.get_upcoming_races()
        
        if not races:
            print("\n📭 No upcoming races")
            return
        
        print("\n📅 UPCOMING RACES")
        print("="*60)
        
        for race in races:
            days_until = (race.race_date - date.today()).days
            print(f"\n🏁 {race.race_name}")
            print(f"   📅 {race.race_date} ({days_until} days)")
            print(f"   📍 {race.race_venue or 'TBD'}")
            print(f"   💰 ${race.entry_fee or 0:.2f}")
    
    def edit_race(self):
        """Edit existing race."""
        race_id = input("\nEnter Race ID to edit: ").strip()
        
        try:
            race = race_manager.get_race_by_id(int(race_id))
            if not race:
                print("❌ Race not found")
                return
            
            print(f"\n✏️ Editing: {race.race_name}")
            print("Press Enter to keep current value")
            
            # Update fields
            race.race_name = input(f"Name [{race.race_name}]: ").strip() or race.race_name
            race.race_venue = input(f"Venue [{race.race_venue}]: ").strip() or race.race_venue
            
            if race_manager.update_race(int(race_id), race):
                print("✅ Race updated successfully!")
            else:
                print("❌ Failed to update race")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def delete_race(self):
        """Delete a race."""
        race_id = input("\nEnter Race ID to delete: ").strip()
        
        try:
            race = race_manager.get_race_by_id(int(race_id))
            if not race:
                print("❌ Race not found")
                return
            
            print(f"\n⚠️ Delete race: {race.race_name}?")
            if input("Type 'DELETE' to confirm: ").strip() == 'DELETE':
                if race_manager.delete_race(int(race_id)):
                    print("✅ Race deleted successfully!")
                else:
                    print("❌ Failed to delete race")
            else:
                print("❌ Deletion cancelled")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def settings_menu(self):
        """Settings menu."""
        print("\n⚙️ SETTINGS")
        print("="*40)
        print(f"Database: {'CLOUD' if self.db_status['is_cloud'] else 'LOCAL'}")
        print(f"Host: {self.db_status['host']}")
        print(f"Database: {self.db_status['database']}")
        print(f"Connected: {'Yes' if self.db_status['connected'] else 'No'}")
    
    def cleanup(self):
        """Cleanup on exit."""
        logger.info("TERS Console shutdown")

def main():
    """Main entry point."""
    app = TERSConsole()
    app.start()

if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}✅ TERS console application created!${NC}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🖼️ CREATE TERS GUI APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🖼️ Creating TERS GUI application...${NC}"

cat > "$TERS_DIR/gui/race_registration_gui.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🖼️ TERS: The Event Registration Solution - GUI Application
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    GTK4-based GUI application for race registration management.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, Gio, GLib

import sys
import os
from pathlib import Path
from datetime import datetime, date
import logging

# Find TEMS base directory
def find_tems_base():
    """Find TEMS base directory from current location."""
    current = Path(__file__).resolve()
    while current != current.parent:
        for parent in current.parents:
            if 'TEMS: The Event Management Solution' in parent.name:
                return parent
        current = current.parent
    return Path(os.environ.get('TEMS_BASE', Path.cwd()))

TEMS_BASE = find_tems_base()
TRDS_DIR = TEMS_BASE / 'TRDS: The Race Data Solution'

# Add TRDS libraries to path
sys.path.insert(0, str(TRDS_DIR / 'libraries'))

from models.race import Race, race_manager
from database.connection import db_manager
from utils.config import config
from utils.paths import paths

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(paths.get_log_dir('ters') / 'gui.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TERSApplication(Adw.Application):
    """Main GTK4 application class."""
    
    def __init__(self):
        """Initialize application."""
        super().__init__(application_id='com.tems.ters')
        self.window = None
        logger.info("TERS GUI Application initialized")
    
    def do_activate(self):
        """Activate application."""
        if not self.window:
            self.window = TERSMainWindow(self)
        self.window.present()
    
    def do_startup(self):
        """Application startup."""
        Adw.Application.do_startup(self)
        
        # Test database connection
        if not db_manager.test_connection():
            dialog = Adw.MessageDialog.new(
                None,
                "Database Connection Failed",
                "Cannot connect to the database. Please check your configuration."
            )
            dialog.add_response("ok", "OK")
            dialog.present()

class TERSMainWindow(Adw.ApplicationWindow):
    """Main application window."""
    
    def __init__(self, app):
        """Initialize main window."""
        super().__init__(application=app)
        
        self.set_title("TERS: The Event Registration Solution")
        self.set_default_size(1200, 800)
        
        # Get database status
        db_status = db_manager.get_status()
        db_type = "☁️ Cloud" if db_status['is_cloud'] else "💾 Local"
        
        # Create header bar
        header = Adw.HeaderBar()
        
        # Add title with database status
        title_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        title_label = Gtk.Label(label="TERS: Event Registration")
        title_label.add_css_class("title")
        subtitle_label = Gtk.Label(label=f"Database: {db_type}")
        subtitle_label.add_css_class("subtitle")
        title_box.append(title_label)
        title_box.append(subtitle_label)
        header.set_title_widget(title_box)
        
        # Add new race button
        new_race_btn = Gtk.Button(label="New Race")
        new_race_btn.add_css_class("suggested-action")
        new_race_btn.connect("clicked", self.on_new_race)
        header.pack_start(new_race_btn)
        
        # Create main content
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        main_box.set_margin_top(12)
        main_box.set_margin_bottom(12)
        main_box.set_margin_start(12)
        main_box.set_margin_end(12)
        
        # Create toolbar
        toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        refresh_btn = Gtk.Button(label="Refresh")
        refresh_btn.connect("clicked", self.refresh_races)
        toolbar.append(refresh_btn)
        
        main_box.append(toolbar)
        
        # Create race list
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        
        self.race_list = Gtk.ListBox()
        self.race_list.add_css_class("boxed-list")
        scrolled.set_child(self.race_list)
        
        main_box.append(scrolled)
        
        # Set content
        content = Adw.ToolbarView()
        content.add_top_bar(header)
        content.set_content(main_box)
        self.set_content(content)
        
        # Load races
        self.refresh_races()
    
    def refresh_races(self, widget=None):
        """Refresh race list."""
        # Clear existing items
        while self.race_list.get_first_child():
            self.race_list.remove(self.race_list.get_first_child())
        
        # Load races
        races = race_manager.get_all_races()
        
        if not races:
            label = Gtk.Label(label="No races found")
            label.set_margin_top(50)
            label.set_margin_bottom(50)
            self.race_list.append(label)
        else:
            for race in races:
                row = self.create_race_row(race)
                self.race_list.append(row)
    
    def create_race_row(self, race):
        """Create a row for race display."""
        row = Gtk.ListBoxRow()
        
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(12)
        box.set_margin_end(12)
        
        # Race info
        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        info_box.set_hexpand(True)
        
        name_label = Gtk.Label(label=race.race_name)
        name_label.add_css_class("heading")
        name_label.set_halign(Gtk.Align.START)
        info_box.append(name_label)
        
        details = f"{race.race_date} • {race.race_venue or 'TBD'}"
        details_label = Gtk.Label(label=details)
        details_label.add_css_class("dim-label")
        details_label.set_halign(Gtk.Align.START)
        info_box.append(details_label)
        
        box.append(info_box)
        
        # Action buttons
        edit_btn = Gtk.Button(label="Edit")
        edit_btn.connect("clicked", self.on_edit_race, race)
        box.append(edit_btn)
        
        delete_btn = Gtk.Button(label="Delete")
        delete_btn.add_css_class("destructive-action")
        delete_btn.connect("clicked", self.on_delete_race, race)
        box.append(delete_btn)
        
        row.set_child(box)
        return row
    
    def on_new_race(self, widget):
        """Handle new race button."""
        dialog = RaceDialog(self, None)
        dialog.present()
    
    def on_edit_race(self, widget, race):
        """Handle edit race button."""
        dialog = RaceDialog(self, race)
        dialog.present()
    
    def on_delete_race(self, widget, race):
        """Handle delete race button."""
        dialog = Adw.MessageDialog.new(
            self,
            f"Delete {race.race_name}?",
            "This action cannot be undone."
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)
        
        dialog.connect("response", self.on_delete_confirmed, race)
        dialog.present()
    
    def on_delete_confirmed(self, dialog, response, race):
        """Handle delete confirmation."""
        if response == "delete":
            if race_manager.delete_race(race.race_id):
                self.refresh_races()

class RaceDialog(Adw.Window):
    """Dialog for creating/editing races."""
    
    def __init__(self, parent, race=None):
        """Initialize race dialog."""
        super().__init__()
        
        self.parent_window = parent
        self.race = race
        
        self.set_title("Edit Race" if race else "New Race")
        self.set_default_size(500, 600)
        self.set_transient_for(parent)
        self.set_modal(True)
        
        # Create header bar
        header = Adw.HeaderBar()
        
        cancel_btn = Gtk.Button(label="Cancel")
        cancel_btn.connect("clicked", lambda x: self.close())
        header.pack_start(cancel_btn)
        
        save_btn = Gtk.Button(label="Save")
        save_btn.add_css_class("suggested-action")
        save_btn.connect("clicked", self.on_save)
        header.pack_end(save_btn)
        
        # Create form
        form_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        form_box.set_margin_top(12)
        form_box.set_margin_bottom(12)
        form_box.set_margin_start(12)
        form_box.set_margin_end(12)
        
        # Form fields
        self.name_entry = Adw.EntryRow()
        self.name_entry.set_title("Race Name")
        if race:
            self.name_entry.set_text(race.race_name)
        form_box.append(self.name_entry)
        
        self.venue_entry = Adw.EntryRow()
        self.venue_entry.set_title("Venue")
        if race:
            self.venue_entry.set_text(race.race_venue or "")
        form_box.append(self.venue_entry)
        
        self.date_entry = Adw.EntryRow()
        self.date_entry.set_title("Date (YYYY-MM-DD)")
        if race:
            self.date_entry.set_text(str(race.race_date))
        form_box.append(self.date_entry)
        
        # Set content
        content = Adw.ToolbarView()
        content.add_top_bar(header)
        
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_child(form_box)
        content.set_content(scrolled)
        
        self.set_content(content)
    
    def on_save(self, widget):
        """Save race data."""
        try:
            if self.race:
                # Update existing
                self.race.race_name = self.name_entry.get_text()
                self.race.race_venue = self.venue_entry.get_text()
                self.race.race_date = datetime.strptime(
                    self.date_entry.get_text(), '%Y-%m-%d'
                ).date()
                
                if race_manager.update_race(self.race.race_id, self.race):
                    self.parent_window.refresh_races()
                    self.close()
            else:
                # Create new
                race = Race(
                    race_name=self.name_entry.get_text(),
                    race_venue=self.venue_entry.get_text(),
                    race_date=datetime.strptime(
                        self.date_entry.get_text(), '%Y-%m-%d'
                    ).date(),
                    race_type="road_race"
                )
                
                if race_manager.create_race(race):
                    self.parent_window.refresh_races()
                    self.close()
                    
        except Exception as e:
            dialog = Adw.MessageDialog.new(self, "Error", str(e))
            dialog.add_response("ok", "OK")
            dialog.present()

def main():
    """Main entry point."""
    app = TERSApplication()
    app.run(sys.argv)

if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}✅ TERS GUI application created!${NC}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 CREATE LAUNCHER SCRIPTS IN TEMS BASE
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🚀 Creating launcher scripts in TEMS base directory...${NC}"

# Create launcher for TERS Console
cat > "$TEMS_BASE/run_ters_console.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TERS Console Launcher
# ═══════════════════════════════════════════════════════════════════════════════

# Detect if we're in Docker
if [ -f /.dockerenv ]; then
    echo "🐳 Running in Docker environment"
    PYTHON_CMD="python3"
else
    echo "💻 Running in local environment"
    
    # Check for virtual environment
    if [ -d "venv" ]; then
        echo "🐍 Activating virtual environment..."
        source venv/bin/activate
        PYTHON_CMD="python"
    elif [ -d ".venv" ]; then
        echo "🐍 Activating virtual environment..."
        source .venv/bin/activate
        PYTHON_CMD="python"
    else
        PYTHON_CMD="python3"
    fi
fi

# Set environment variables
export TEMS_BASE="$(pwd)"
export TEMS_ENV="${TEMS_ENV:-development}"

# Run TERS console
echo "🏁 Starting TERS: The Event Registration Solution (Console)"
echo "════════════════════════════════════════════════════════════"

cd "TERS: The Event Registration Solution/console"
$PYTHON_CMD race_registration_console.py
EOF

chmod +x "$TEMS_BASE/run_ters_console.sh"

# Create launcher for TERS GUI
cat > "$TEMS_BASE/run_ters_gui.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🖼️ TERS GUI Launcher
# ═══════════════════════════════════════════════════════════════════════════════

# Detect if we're in Docker
if [ -f /.dockerenv ]; then
    echo "🐳 Running in Docker environment"
    PYTHON_CMD="python3"
else
    echo "💻 Running in local environment"
    
    # Check for virtual environment
    if [ -d "venv" ]; then
        echo "🐍 Activating virtual environment..."
        source venv/bin/activate
        PYTHON_CMD="python"
    elif [ -d ".venv" ]; then
        echo "🐍 Activating virtual environment..."
        source .venv/bin/activate
        PYTHON_CMD="python"
    else
        PYTHON_CMD="python3"
    fi
fi

# Set environment variables
export TEMS_BASE="$(pwd)"
export TEMS_ENV="${TEMS_ENV:-development}"

# Check for display
if [ -z "$DISPLAY" ]; then
    echo "⚠️  Warning: No display detected. Setting DISPLAY=:0"
    export DISPLAY=:0
fi

# Run TERS GUI
echo "🖼️ Starting TERS: The Event Registration Solution (GUI)"
echo "════════════════════════════════════════════════════════════"

cd "TERS: The Event Registration Solution/gui"
$PYTHON_CMD race_registration_gui.py
EOF

chmod +x "$TEMS_BASE/run_ters_gui.sh"

# Create launcher for TRTS Console
cat > "$TEMS_BASE/run_trts_console.sh" << 'EOF'