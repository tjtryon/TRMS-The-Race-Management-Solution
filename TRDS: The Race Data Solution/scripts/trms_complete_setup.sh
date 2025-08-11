#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TRMS: The Race Management Solution - Complete Setup Script
# ═══════════════════════════════════════════════════════════════════════════════
# 
# 📝 DESCRIPTION:
#     Unified setup script for the complete Race Management Solution ecosystem
#     including TRRS (Registration), TRTS (Timing), TRWS (Web), and TRDS (Data)
#
# 🏗️ ARCHITECTURE:
#     TRMS: The Race Management Solution/
#     ├── TRRS: The Race Registration Solution/
#     ├── TRTS: The Race Timing Solution/ (from GitHub)
#     ├── TRWS: The Race Web Solution/
#     └── TRDS: The Race Data Solution/
#
# 🚀 USAGE:
#     chmod +x TRMS_Complete_Setup.sh
#     ./TRMS_Complete_Setup.sh
#
# 👤 AUTHOR: TRMS Development Team
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
# 🔍 CHECK DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🏁 TRMS: The Race Management Solution - Complete Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}🔍 Checking dependencies...${NC}"

# Check for Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed!${NC}"
    echo "Please install Git to clone TRTS repository:"
    echo "  Ubuntu/Debian: sudo apt install git"
    echo "  macOS: brew install git"
    echo "  Windows: Download from https://git-scm.com"
    exit 1
else
    echo -e "${GREEN}✅ Git found: $(git --version)${NC}"
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed!${NC}"
    echo "Please install Python 3.8 or higher"
    exit 1
else
    echo -e "${GREEN}✅ Python found: $(python3 --version)${NC}"
fi

# Check for Docker (optional)
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker found: $(docker --version)${NC}"
    DOCKER_AVAILABLE=true
else
    echo -e "${YELLOW}⚠️ Docker not found (optional)${NC}"
    DOCKER_AVAILABLE=false
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 AUTO-DETECT AND SET UP DIRECTORY STRUCTURE
# ═══════════════════════════════════════════════════════════════════════════════

# Function to find or create TRMS base directory
find_or_create_trms_base() {
    local current_dir=$(pwd)
    local script_dir=$(dirname "$(readlink -f "$0")")
    
    # Check if we're already in TRMS or a subdirectory
    if [[ "$current_dir" == *"TRMS: The Race Management Solution"* ]]; then
        # Navigate up to TRMS root
        while [[ "$(basename "$current_dir")" != "TRMS: The Race Management Solution" ]] && [ "$current_dir" != "/" ]; do
            current_dir=$(dirname "$current_dir")
        done
        echo "$current_dir"
    elif [[ -d "$current_dir/TRMS: The Race Management Solution" ]]; then
        echo "$current_dir/TRMS: The Race Management Solution"
    else
        # Create TRMS in current directory
        echo "$current_dir/TRMS: The Race Management Solution"
    fi
}

# Set up base directories
TRMS_BASE=$(find_or_create_trms_base)
echo -e "${BLUE}📁 Setting up TRMS base directory at: ${WHITE}$TRMS_BASE${NC}"

# Create TRMS base if it doesn't exist
if [ ! -d "$TRMS_BASE" ]; then
    echo -e "${YELLOW}📦 Creating TRMS base directory structure...${NC}"
    mkdir -p "$TRMS_BASE"
fi

cd "$TRMS_BASE"

# Define all solution directories with full names
TRRS_DIR="$TRMS_BASE/TRRS: The Race Registration Solution"
TRTS_DIR="$TRMS_BASE/TRTS: The Race Timing Solution"
TRWS_DIR="$TRMS_BASE/TRWS: The Race Web Solution"
TRDS_DIR="$TRMS_BASE/TRDS: The Race Data Solution"

# Export for use in Python scripts
export TRMS_BASE
export TRRS_DIR
export TRTS_DIR
export TRWS_DIR
export TRDS_DIR

echo -e "${GREEN}✅ Directory variables set:${NC}"
echo -e "   ${WHITE}TRMS_BASE:${NC} $TRMS_BASE"
echo -e "   ${WHITE}TRRS_DIR:${NC} $TRRS_DIR"
echo -e "   ${WHITE}TRTS_DIR:${NC} $TRTS_DIR"
echo -e "   ${WHITE}TRWS_DIR:${NC} $TRWS_DIR"
echo -e "   ${WHITE}TRDS_DIR:${NC} $TRDS_DIR"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 CREATE COMPLETE DIRECTORY STRUCTURE
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📁 Creating complete TRMS directory structure...${NC}"

# Create TRRS directories (Race Registration Solution)
mkdir -p "$TRRS_DIR"/{console,gui,scripts,docs,tests/{unit,integration}}

# Clone or update TRTS from GitHub (Race Timing Solution)
if [ ! -d "$TRTS_DIR" ]; then
    echo -e "${YELLOW}📥 Cloning TRTS from GitHub...${NC}"
    git clone https://github.com/tjtryon/TRTS-The-Race-Timing-Solution.git "$TRTS_DIR"
    echo -e "${GREEN}✅ TRTS cloned successfully!${NC}"
else
    echo -e "${YELLOW}🔄 TRTS directory exists, checking for updates...${NC}"
    cd "$TRTS_DIR"
    if [ -d ".git" ]; then
        git pull
        echo -e "${GREEN}✅ TRTS updated!${NC}"
    else
        echo -e "${YELLOW}⚠️  TRTS directory exists but is not a git repository${NC}"
    fi
    cd "$TRMS_BASE"
fi

# Create TRWS directories (Race Web Solution)
mkdir -p "$TRWS_DIR"/web/{templates/{base,trrs,trts,shared},static/{css,js,images,fonts}}
mkdir -p "$TRWS_DIR"/nginx/{conf.d,ssl}
mkdir -p "$TRWS_DIR"/docker
mkdir -p "$TRWS_DIR"/api/{trrs,trts,shared}
mkdir -p "$TRWS_DIR"/scripts

# Create TRDS directories (Race Data Solution)
mkdir -p "$TRDS_DIR"/databases/{mysql,backups}
mkdir -p "$TRDS_DIR"/logs/{trrs,trts,web,system}
mkdir -p "$TRDS_DIR"/sql/{init,migrations,stored_procedures}
mkdir -p "$TRDS_DIR"/libraries/{database,utils,models,api}
mkdir -p "$TRDS_DIR"/config/{development,staging,production,docker}
mkdir -p "$TRDS_DIR"/backups/{daily,weekly,monthly}
mkdir -p "$TRDS_DIR"/docker
mkdir -p "$TRDS_DIR"/scripts

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
🗺️ TRMS Path Resolution Utility
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Automatic path resolution for TRMS ecosystem. Finds directories regardless
    of where scripts are run from.

👤 AUTHOR: TRMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
from pathlib import Path
from typing import Optional

class TRMSPaths:
    """Path resolver for TRMS ecosystem."""
    
    @staticmethod
    def find_trms_base() -> Path:
        """Find the TRMS base directory from any location."""
        # Check environment variable first
        if 'TRMS_BASE' in os.environ:
            return Path(os.environ['TRMS_BASE'])
        
        # Start from current file location
        current = Path(__file__).resolve()
        
        # Navigate up until we find TRMS
        while current != current.parent:
            if 'TRMS: The Race Management Solution' in current.name:
                return current
            # Check all parents
            for parent in current.parents:
                if 'TRMS: The Race Management Solution' in parent.name:
                    return parent
            current = current.parent
        
        # Try from current working directory
        cwd = Path.cwd()
        if 'TRMS: The Race Management Solution' in str(cwd):
            parts = str(cwd).split('TRMS: The Race Management Solution')
            return Path(parts[0]) / 'TRMS: The Race Management Solution'
        
        # Default fallback
        return Path.cwd() / 'TRMS: The Race Management Solution'
    
    def __init__(self):
        """Initialize paths for TRMS ecosystem."""
        self.TRMS_BASE = self.find_trms_base()
        self.TRRS_DIR = self.TRMS_BASE / 'TRRS: The Race Registration Solution'
        self.TRTS_DIR = self.TRMS_BASE / 'TRTS: The Race Timing Solution'
        self.TRWS_DIR = self.TRMS_BASE / 'TRWS: The Race Web Solution'
        self.TRDS_DIR = self.TRMS_BASE / 'TRDS: The Race Data Solution'
        
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
paths = TRMSPaths()

# Export commonly used paths
TRMS_BASE = paths.TRMS_BASE
TRRS_DIR = paths.TRRS_DIR
TRTS_DIR = paths.TRTS_DIR
TRWS_DIR = paths.TRWS_DIR
TRDS_DIR = paths.TRDS_DIR
EOF

# Create configuration management module
cat > "$TRDS_DIR/libraries/utils/config.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
⚙️ TRMS Unified Configuration Management
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Centralized configuration for all TRMS solutions with automatic cloud/local
    database switching and Docker support.

👤 AUTHOR: TRMS Development Team
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
from .paths import paths, TRMS_BASE, TRDS_DIR

class DatabaseConfig(BaseModel):
    """Database configuration with cloud/local support."""
    # Local database settings
    local_host: str = Field(default="localhost", description="Local database host")
    local_port: int = Field(default=3306, description="Local database port")
    
    # Cloud database settings
    cloud_host: Optional[str] = Field(default=None, description="Cloud database host")
    cloud_port: int = Field(default=3306, description="Cloud database port")
    
    # Shared settings
    database: str = Field(default="trms_db", description="Database name")
    user: str = Field(default="trms", description="Database user")
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
    trrs_api_url: str = Field(default="/api/trrs", description="TRRS API endpoint")
    trts_api_url: str = Field(default="/api/trts", description="TRTS API endpoint")

class DockerConfig(BaseModel):
    """Docker deployment configuration."""
    compose_file: str = Field(default="docker-compose.yml", description="Compose file")
    network_name: str = Field(default="trms-network", description="Docker network")
    
    # Service names
    db_service: str = Field(default="trms-db", description="Database service")
    web_service: str = Field(default="trms-web", description="Web service")
    nginx_service: str = Field(default="trms-nginx", description="Nginx service")
    
    # Volumes
    use_volumes: bool = Field(default=True, description="Use Docker volumes")
    
class LoggingConfig(BaseModel):
    """Logging configuration."""
    level: str = Field(default="INFO", description="Log level")
    format: str = Field(default="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    
    # Log rotation
    max_bytes: int = Field(default=10485760, description="Max log file size (10MB)")
    backup_count: int = Field(default=5, description="Number of backup files")

class TRMSConfig(BaseModel):
    """Master configuration for TRMS ecosystem."""
    # Environment
    environment: str = Field(default="development", description="Environment name")
    version: str = Field(default="1.0.0", description="TRMS version")
    
    # Component configurations
    database: DatabaseConfig = Field(default_factory=DatabaseConfig)
    web: WebConfig = Field(default_factory=WebConfig)
    docker: DockerConfig = Field(default_factory=DockerConfig)
    logging: LoggingConfig = Field(default_factory=LoggingConfig)
    
    # Paths (auto-populated)
    trms_base: Path = Field(default_factory=lambda: TRMS_BASE)
    trds_dir: Path = Field(default_factory=lambda: TRDS_DIR)
    
    def save(self, environment: Optional[str] = None):
        """Save configuration to file."""
        env = environment or self.environment
        config_file = self.trds_dir / 'config' / f'{env}.yaml'
        config_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(config_file, 'w') as f:
            yaml.dump(self.dict(), f, default_flow_style=False)

def load_config(environment: Optional[str] = None) -> TRMSConfig:
    """Load configuration from file and environment variables."""
    # Determine environment
    if not environment:
        environment = os.getenv('TRMS_ENV', 'development')
    
    # Load from config file
    config_file = TRDS_DIR / 'config' / f'{environment}.yaml'
    
    if config_file.exists():
        with open(config_file, 'r') as f:
            config_data = yaml.safe_load(f) or {}
        config = TRMSConfig(**config_data)
    else:
        config = TRMSConfig(environment=environment)
    
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
🔌 TRMS Unified Database Connection Management
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Database connection management with automatic cloud/local switching,
    connection pooling, and failover support.

👤 AUTHOR: TRMS Development Team
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
                'pool_name': 'trms_cloud_pool',
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
                'pool_name': 'trms_local_pool',
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
🏁 Race Models for TRMS
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Shared race models used by both TRRS and TRTS.

👤 AUTHOR: TRMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

from typing import Optional, List
from datetime import datetime, date, time
from pydantic import BaseModel, Field, validator
from ..database.connection import db_manager

class Race(BaseModel):
    """Race model for TRMS ecosystem."""
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
    
    # TRRS specific fields
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
            return [Race(**row) for row in results]
        except Exception as e:
            print(f"Error fetching upcoming races: {e}")
            return []

# Global race manager
race_manager = RaceManager()
EOF

echo -e "${GREEN}✅ Shared libraries created in TRDS!${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 🖥️ CREATE TRRS CONSOLE APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🖥️ Creating TRRS console application...${NC}"

cat > "$TRRS_DIR/console/race_registration_console.py" << 'EOF'
#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 TRRS: The Race Registration Solution - Console Application
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Console application for race registration management. Part of the TRMS
    ecosystem, working alongside TRTS for complete race management.

👤 AUTHOR: TRMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import sys
import os
from pathlib import Path
from datetime import datetime, date, time
import logging

# Find TRMS base directory and add libraries to path
def find_trms_base():
    """Find TRMS base directory from current location."""
    current = Path(__file__).resolve()
    while current != current.parent:
        for parent in current.parents:
            if 'TRMS: The Race Management Solution' in parent.name:
                return parent
        current = current.parent
    return Path(os.environ.get('TRMS_BASE', Path.cwd()))

TRMS_BASE = find_trms_base()
TRDS_DIR = TRMS_BASE / 'TRDS: The Race Data Solution'

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
        logging.FileHandler(paths.get_log_dir('trrs') / 'console.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TRRSConsole:
    """Main console application for TRRS."""
    
    def __init__(self):
        """Initialize the console application."""
        self.running = False
        self.db_status = db_manager.get_status()
        logger.info(f"TRRS Console initialized - Database: {'CLOUD' if self.db_status['is_cloud'] else 'LOCAL'}")
    
    def start(self):
        """Start the console application."""
        try:
            logger.info("Starting TRRS Console Application")
            
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
        print("   🏁 TRRS: The Race Registration Solution")
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
            print("\n👋 Thank you for using TRRS!")
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
        logger.info("TRRS Console shutdown")

def main():
    """Main entry point."""
    app = TRRSConsole()
    app.start()

if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}✅ TRRS console application created!${NC}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 CREATE LAUNCHER SCRIPTS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🚀 Creating launcher scripts...${NC}"

# Create launcher for TRRS Console
cat > "$TRMS_BASE/run_trrs_console.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TRRS Console Launcher
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
export TRMS_BASE="$(pwd)"
export TRMS_ENV="${TRMS_ENV:-development}"

# Run TRRS console
echo "🏁 Starting TRRS: The Race Registration Solution (Console)"
echo "════════════════════════════════════════════════════════════"

cd "TRRS: The Race Registration Solution/console"
$PYTHON_CMD race_registration_console.py
EOF

chmod +x "$TRMS_BASE/run_trrs_console.sh"

# Create launcher for TRTS Console
cat > "$TRMS_BASE/run_trts_console.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# ⏱️ TRTS Console Launcher
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
export TRMS_BASE="$(pwd)"
export TRMS_ENV="${TRMS_ENV:-development}"

# Run TRTS console
echo "⏱️ Starting TRTS: The Race Timing Solution (Console)"
echo "════════════════════════════════════════════════════════════════════════════════"

cd "TRTS: The Race Timing Solution"

# Check for the actual TRTS console file structure from GitHub
if [ -f "race_timing_console.py" ]; then
    $PYTHON_CMD race_timing_console.py
elif [ -f "console/race_timing_console.py" ]; then
    cd console
    $PYTHON_CMD race_timing_console.py
elif [ -f "src/race_timing_console.py" ]; then
    cd src
    $PYTHON_CMD race_timing_console.py
else
    echo "⚠️  TRTS console application not found"
    echo "Please ensure TRTS is properly installed from GitHub"
    echo "Repository: https://github.com/tjtryon/TRTS-The-Race-Timing-Solution"
fi
EOF

chmod +x "$TRMS_BASE/run_trts_console.sh"

# Create master launcher script
cat > "$TRMS_BASE/trms_launcher.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TRMS: The Race Management Solution - Master Launcher
# ═══════════════════════════════════════════════════════════════════════════════

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🏁 TRMS: The Race Management Solution${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Set environment
export TRMS_BASE="$(pwd)"

# Detect environment
if [ -f /.dockerenv ]; then
    echo -e "${BLUE}🐳 Environment: Docker${NC}"
    PYTHON_CMD="python3"
else
    echo -e "${BLUE}💻 Environment: Local${NC}"
    
    # Check for virtual environment
    if [ -d "venv" ] || [ -d ".venv" ]; then
        echo -e "${GREEN}🐍 Virtual environment detected${NC}"
        if [ -d "venv" ]; then
            source venv/bin/activate
        else
            source .venv/bin/activate
        fi
        PYTHON_CMD="python"
    else
        PYTHON_CMD="python3"
    fi
fi

# Check database environment
if [ "$USE_CLOUD_DB" = "true" ]; then
    echo -e "${YELLOW}☁️  Database: Cloud${NC}"
else
    echo -e "${YELLOW}💾 Database: Local${NC}"
fi

echo ""
echo -e "${WHITE}Select an application to launch:${NC}"
echo ""
echo -e "${GREEN}TRRS: The Race Registration Solution${NC}"
echo "  1) 🖥️  Console Application"
echo "  2) 🖼️  GUI Application (Coming Soon)"
echo ""
echo -e "${BLUE}TRTS: The Race Timing Solution${NC}"
echo "  3) 🖥️  Console Application"
echo "  4) 🖼️  GUI Application"
echo ""
echo -e "${MAGENTA}System Utilities${NC}"
echo "  5) 🔧 Database Setup"
echo "  6) 📊 System Status"
echo "  7) 🌐 Launch Web Interface (Coming Soon)"
echo "  8) 🐳 Docker Management"
echo ""
echo "  0) Exit"
echo ""

read -p "Enter selection [0-8]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Launching TRRS Console...${NC}"
        ./run_trrs_console.sh
        ;;
    2)
        echo -e "\n${GREEN}TRRS GUI coming soon!${NC}"
        echo "For now, please use the console application."
        ;;
    3)
        echo -e "\n${BLUE}Launching TRTS Console...${NC}"
        ./run_trts_console.sh
        ;;
    4)
        echo -e "\n${BLUE}Launching TRTS GUI...${NC}"
        cd "TRTS: The Race Timing Solution"
        if [ -f "race_timing_gui.py" ]; then
            $PYTHON_CMD race_timing_gui.py
        else
            echo "TRTS GUI not found in expected location"
        fi
        ;;
    5)
        echo -e "\n${MAGENTA}Database Setup${NC}"
        echo "Creating database schema..."
        # Database setup will be implemented
        ;;
    6)
        echo -e "\n${MAGENTA}System Status${NC}"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo -e "TRMS Base: ${WHITE}$TRMS_BASE${NC}"
        echo -e "Python: ${WHITE}$(which $PYTHON_CMD)${NC}"
        echo -e "Environment: ${WHITE}${TRMS_ENV:-development}${NC}"
        
        echo -e "\nDirectory Structure:"
        for dir in "TRRS: The Race Registration Solution" "TRTS: The Race Timing Solution" "TRWS: The Race Web Solution" "TRDS: The Race Data Solution"; do
            if [ -d "$dir" ]; then
                echo -e "  ${GREEN}✅${NC} $dir"
            else
                echo -e "  ${RED}❌${NC} $dir"
            fi
        done
        
        read -p "Press Enter to continue..."
        $0
        ;;
    7)
        echo -e "\n${MAGENTA}Web Interface coming soon!${NC}"
        echo "TRWS: The Race Web Solution will provide unified web access."
        ;;
    8)
        if [ "$DOCKER_AVAILABLE" = "true" ]; then
            echo -e "\n${MAGENTA}Docker Management${NC}"
            echo "1) Start Docker services"
            echo "2) Stop Docker services"  
            echo "3) View Docker status"
            echo "4) View logs"
            read -p "Select option: " docker_choice
            
            case $docker_choice in
                1) echo "Docker services starting..." ;;
                2) echo "Docker services stopping..." ;;
                3) echo "Docker status..." ;;
                4) echo "Docker logs..." ;;
            esac
        else
            echo -e "\n${RED}Docker not available${NC}"
        fi
        ;;
    0)
        echo -e "\n${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${RED}Invalid selection${NC}"
        sleep 2
        $0
        ;;
esac
EOF

chmod +x "$TRMS_BASE/trms_launcher.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 CREATE PYTHON REQUIREMENTS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📦 Creating Python requirements...${NC}"

cat > "$TRMS_BASE/requirements.txt" << 'EOF'
# TRMS: The Race Management Solution - Python Dependencies
# ═══════════════════════════════════════════════════════════════════════════════

# Core dependencies
pydantic>=2.0.0
PyYAML>=6.0.0
mysql-connector-python>=8.0.0

# Development dependencies
python-dotenv>=1.0.0

# Logging
structlog>=23.0.0

# Optional GUI dependencies (for future TRRS GUI)
# PyGObject>=3.40.0  # Uncomment when implementing GTK4 GUI

# Optional web dependencies (for future TRWS)
# flask>=2.3.0       # Uncomment when implementing web interface
# flask-cors>=4.0.0  # Uncomment when implementing web interface

# Testing dependencies (optional)
# pytest>=7.0.0
# pytest-cov>=4.0.0
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# 📄 CREATE README AND DOCUMENTATION
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📄 Creating documentation...${NC}"

cat > "$TRMS_BASE/README.md" << 'EOF'
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
EOF

# Create .gitignore
cat > "$TRMS_BASE/.gitignore" << 'EOF'
# TRMS: The Race Management Solution - Git Ignore
# ═══════════════════════════════════════════════════════════════════════════════

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
.venv/
env/
ENV/

# Database
*.db
*.sqlite3

# Logs
*.log
TRDS: The Race Data Solution/logs/

# Configuration
.env
*.secret

# Backups
TRDS: The Race Data Solution/backups/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Docker
.docker/

# Temporary files
*.tmp
*.temp
*~
EOF

echo -e "${GREEN}✅ Documentation created!${NC}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 CREATE DATABASE SCHEMA
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🔧 Creating database schema...${NC}"

mkdir -p "$TRDS_DIR/sql/init"

cat > "$TRDS_DIR/sql/init/01_create_database.sql" << 'EOF'
-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗄️ TRMS Database Schema
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create database
CREATE DATABASE IF NOT EXISTS trms_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER IF NOT EXISTS 'trms'@'%' IDENTIFIED BY 'trms_password_2024';
GRANT ALL PRIVILEGES ON trms_db.* TO 'trms'@'%';
FLUSH PRIVILEGES;

USE trms_db;
EOF

cat > "$TRDS_DIR/sql/init/02_create_tables.sql" << 'EOF'
-- ═══════════════════════════════════════════════════════════════════════════════
-- 📊 TRMS Tables Schema
-- ═══════════════════════════════════════════════════════════════════════════════

USE trms_db;

-- =============================================
-- RACES TABLE (Shared by TRRS and TRTS)
-- =============================================
CREATE TABLE IF NOT EXISTS races (
    race_id INT AUTO_INCREMENT PRIMARY KEY,
    race_name VARCHAR(255) NOT NULL,
    race_description TEXT,
    race_date DATE NOT NULL,
    race_time TIME,
    race_venue VARCHAR(255),
    race_type ENUM('road_race', 'cross_country', 'track', 'trail', 'virtual', 'triathlon') DEFAULT 'road_race',
    race_distances VARCHAR(500),
    course_link VARCHAR(500),
    registration_link VARCHAR(500),
    
    -- TRRS specific fields
    registration_open BOOLEAN DEFAULT TRUE,
    registration_limit INT,
    entry_fee DECIMAL(10,2),
    
    -- TRTS specific fields
    timing_method VARCHAR(50),
    chip_timing BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_race_date (race_date),
    INDEX idx_race_type (race_type),
    INDEX idx_race_name (race_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- PARTICIPANTS TABLE (TRRS)
-- =============================================
CREATE TABLE IF NOT EXISTS participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    race_id INT NOT NULL,
    
    -- Personal information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Race specific
    distance VARCHAR(50),
    bib_number VARCHAR(20),
    t_shirt_size ENUM('XS', 'S', 'M', 'L', 'XL', 'XXL'),
    
    -- Emergency contact
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    
    -- Registration
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registration_status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    amount_paid DECIMAL(10,2),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (race_id) REFERENCES races(race_id) ON DELETE CASCADE,
    INDEX idx_race_participant (race_id, last_name, first_name),
    INDEX idx_email (email),
    INDEX idx_bib_number (bib_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- RACE_TIMES TABLE (TRTS)
-- =============================================
CREATE TABLE IF NOT EXISTS race_times (
    time_id INT AUTO_INCREMENT PRIMARY KEY,
    race_id INT NOT NULL,
    participant_id INT,
    bib_number VARCHAR(20),
    
    -- Timing data
    start_time TIMESTAMP,
    finish_time TIMESTAMP,
    net_time TIME GENERATED ALWAYS AS (
        CASE 
            WHEN finish_time IS NOT NULL AND start_time IS NOT NULL 
            THEN TIMEDIFF(finish_time, start_time)
            ELSE NULL 
        END
    ) STORED,
    
    -- Split times (JSON format for flexibility)
    split_times JSON,
    
    -- Placement
    overall_place INT,
    gender_place INT,
    age_group_place INT,
    
    -- Status
    timing_status ENUM('started', 'finished', 'dnf', 'dsq') DEFAULT 'started',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (race_id) REFERENCES races(race_id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id) ON DELETE SET NULL,
    INDEX idx_race_times (race_id, finish_time),
    INDEX idx_bib_number (bib_number),
    INDEX idx_participant (participant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SYSTEM_SETTINGS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    component ENUM('TRMS', 'TRRS', 'TRTS', 'TRWS', 'TRDS') DEFAULT 'TRMS',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT IGNORE INTO system_settings (setting_key, setting_value, description, component) VALUES
('trms_version', '1.0.0', 'TRMS version', 'TRMS'),
('default_race_type', 'road_race', 'Default race type for new races', 'TRRS'),
('enable_chip_timing', 'false', 'Enable chip timing by default', 'TRTS'),
('registration_email_enabled', 'true', 'Send confirmation emails', 'TRRS');
EOF

cat > "$TRDS_DIR/sql/init/03_create_views.sql" << 'EOF'
-- ═══════════════════════════════════════════════════════════════════════════════
-- 👁️ TRMS Database Views
-- ═══════════════════════════════════════════════════════════════════════════════

USE trms_db;

-- =============================================
-- RACE SUMMARY VIEW
-- =============================================
CREATE OR REPLACE VIEW race_summary AS
SELECT 
    r.race_id,
    r.race_name,
    r.race_date,
    r.race_venue,
    r.race_type,
    r.registration_open,
    COUNT(DISTINCT p.participant_id) as registered_count,
    COUNT(DISTINCT rt.participant_id) as finished_count,
    r.registration_limit,
    r.entry_fee,
    CASE 
        WHEN r.race_date > CURDATE() THEN 'upcoming'
        WHEN r.race_date = CURDATE() THEN 'today'
        ELSE 'completed'
    END as status
FROM races r
LEFT JOIN participants p ON r.race_id = p.race_id AND p.registration_status = 'confirmed'
LEFT JOIN race_times rt ON r.race_id = rt.race_id AND rt.timing_status = 'finished'
GROUP BY r.race_id;

-- =============================================
-- PARTICIPANT DETAILS VIEW
-- =============================================
CREATE OR REPLACE VIEW participant_details AS
SELECT 
    p.participant_id,
    p.race_id,
    r.race_name,
    CONCAT(p.first_name, ' ', p.last_name) as full_name,
    p.email,
    p.phone,
    p.distance,
    p.bib_number,
    p.registration_status,
    p.payment_status,
    p.amount_paid,
    rt.finish_time,
    rt.net_time,
    rt.overall_place,
    rt.timing_status
FROM participants p
JOIN races r ON p.race_id = r.race_id
LEFT JOIN race_times rt ON p.participant_id = rt.participant_id;

-- =============================================
-- RACE RESULTS VIEW
-- =============================================
CREATE OR REPLACE VIEW race_results AS
SELECT 
    rt.race_id,
    r.race_name,
    rt.participant_id,
    CONCAT(p.first_name, ' ', p.last_name) as participant_name,
    rt.bib_number,
    p.distance,
    rt.start_time,
    rt.finish_time,
    rt.net_time,
    rt.overall_place,
    rt.gender_place,
    rt.age_group_place,
    rt.timing_status
FROM race_times rt
JOIN races r ON rt.race_id = r.race_id
LEFT JOIN participants p ON rt.participant_id = p.participant_id
WHERE rt.timing_status IN ('finished', 'dnf', 'dsq')
ORDER BY rt.race_id, rt.overall_place;
EOF

echo -e "${GREEN}✅ Database schema created!${NC}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 CREATE DATABASE SETUP SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}🔧 Creating database setup script...${NC}"

cat > "$TRDS_DIR/scripts/setup_database.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🗄️ TRMS Database Setup Script
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️ TRMS Database Setup${NC}"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRDS_DIR="$(dirname "$SCRIPT_DIR")"
SQL_DIR="$TRDS_DIR/sql/init"

# Database connection parameters
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-}"
DB_USER="${DB_USER:-trms}"
DB_PASSWORD="${DB_PASSWORD:-trms_password_2024}"
DB_NAME="${DB_NAME:-trms_db}"

echo -e "${YELLOW}Database Configuration:${NC}"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL client not found!${NC}"
    echo "Please install MySQL client:"
    echo "  Ubuntu/Debian: sudo apt install mysql-client"
    echo "  macOS: brew install mysql-client"
    exit 1
fi

# Test connection
echo -e "${YELLOW}🔍 Testing database connection...${NC}"
if [ -n "$DB_ROOT_PASSWORD" ]; then
    mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null
else
    mysql -h "$DB_HOST" -P "$DB_PORT" -u root -e "SELECT 1;" &>/dev/null
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Cannot connect to database${NC}"
    echo "Please check your database server and credentials."
    exit 1
fi

# Execute SQL files
echo -e "${YELLOW}📊 Creating database schema...${NC}"

for sql_file in "$SQL_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo -e "${BLUE}  Executing: $filename${NC}"
        
        if [ -n "$DB_ROOT_PASSWORD" ]; then
            mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASSWORD" < "$sql_file"
        else
            mysql -h "$DB_HOST" -P "$DB_PORT" -u root < "$sql_file"
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}    ✅ Success${NC}"
        else
            echo -e "${RED}    ❌ Failed${NC}"
            exit 1
        fi
    fi
done

# Test the created database
echo -e "${YELLOW}🧪 Testing created database...${NC}"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" &>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database setup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Database ready for TRMS applications:${NC}"
    echo "  • TRRS: The Race Registration Solution"
    echo "  • TRTS: The Race Timing Solution"
    echo "  • TRWS: The Race Web Solution"
    echo ""
    echo -e "${YELLOW}Connection details:${NC}"
    echo "  Host: $DB_HOST"
    echo "  Database: $DB_NAME"
    echo "  User: $DB_USER"
    echo "  Password: $DB_PASSWORD"
else
    echo -e "${RED}❌ Database test failed${NC}"
    exit 1
fi
EOF

chmod +x "$TRDS_DIR/scripts/setup_database.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# 📄 CREATE README FILES AND LICENSE
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📄 Creating README files and LICENSE...${NC}"

# Create TRDS README.md
cat > "$TRDS_DIR/README.md" << 'EOF'
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
EOF

# Create TRRS README.md
cat > "$TRRS_DIR/README.md" << 'EOF'
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
EOF

# Create TRWS README.md
cat > "$TRWS_DIR/README.md" << 'EOF'
# 🌐 TRWS: The Race Web Solution

**Unified web interface for race management, registration, and timing in the TRMS ecosystem**

## 🎯 Purpose

TRWS provides a modern web interface that unifies all TRMS components:
- **Race registration** - Online participant registration (TRRS integration)
- **Race timing** - Live timing and results display (TRTS integration)  
- **Race management** - Administrative interface for race directors
- **Public portal** - Race information and results for participants
- **API endpoints** - RESTful API for mobile apps and integrations

## 🚧 Development Status

### Current Status: **Planning/Framework Phase**

✅ **Completed**
- Directory structure created
- Integration architecture planned
- Documentation framework
- TRDS integration points identified

🔄 **In Progress**
- Technical specification
- UI/UX design mockups
- API endpoint design

📋 **Planned for Next Release**
- Basic Flask application setup
- TRRS integration for race display
- Simple registration forms
- Admin authentication system

## 🛣️ Roadmap

### Phase 1: Foundation (v0.1.0)
- Basic Flask web application
- Race listing and details pages
- TRDS integration for data access
- Basic responsive design

### Phase 2: Registration (v0.2.0)
- Online race registration
- Payment processing integration
- Email confirmation system

### Phase 3: Timing Integration (v0.3.0)
- TRTS integration for live timing
- Real-time results display
- WebSocket implementation

### Phase 4: Production Ready (v1.0.0)
- Performance optimization
- Security hardening
- Comprehensive testing

## 🔌 API Endpoints (Planned)

### TRRS Integration Endpoints

```bash
# Race management
GET    /api/trrs/races              # List races
POST   /api/trrs/races              # Create race
GET    /api/trrs/races/{id}         # Get race details

# Registration management
GET    /api/trrs/races/{id}/participants    # List participants
POST   /api/trrs/races/{id}/register        # Register participant
```

### TRTS Integration Endpoints

```bash
# Timing data
GET    /api/trts/races/{id}/times           # Get race times
GET    /api/trts/races/{id}/results         # Get results
GET    /api/trts/races/{id}/live            # Live timing feed
```

## 🔧 Technology Stack (Planned)

### Backend
- **Python 3.8+** - Core application language
- **Flask 2.3+** - Web framework
- **TRDS Libraries** - Database and shared functionality

### Frontend
- **HTML5** - Semantic markup
- **CSS3** - Modern styling
- **JavaScript ES6+** - Interactive functionality
- **WebSockets** - Real-time updates

## 📋 Requirements

### System Requirements
- **Operating System**: Linux, macOS, Windows
- **Python**: 3.8 or higher
- **Node.js**: 16+ (for frontend build tools)
- **Database**: MySQL 8.0+ or MariaDB 10.5+ (via TRDS)

## 📜 License

See LICENSE file in this directory.

---

*TRWS provides the web interface for the entire TRMS ecosystem.*
EOF

# Create MIT LICENSE files for all components
echo -e "${YELLOW}📜 Creating MIT LICENSE files...${NC}"

# Current year
CURRENT_YEAR=$(date +%Y)

# MIT License content (same as TRTS)
MIT_LICENSE="MIT License

Copyright (c) $CURRENT_YEAR TRMS Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."

# Create LICENSE files
license_files=(
    "$TRDS_DIR/LICENSE|TRDS: The Race Data Solution"
    "$TRRS_DIR/LICENSE|TRRS: The Race Registration Solution"
    "$TRWS_DIR/LICENSE|TRWS: The Race Web Solution"
    "$TRMS_BASE/LICENSE|TRMS: The Race Management Solution (root)"
)

for license_file in "${license_files[@]}"; do
    IFS='|' read -r file_path component_name <<< "$license_file"
    
    if echo "$MIT_LICENSE" > "$file_path" 2>/dev/null; then
        echo -e "${GREEN}  ✅ Created LICENSE: ${WHITE}$component_name${NC}"
    else
        echo -e "${RED}  ❌ Failed to create LICENSE: ${WHITE}$component_name${NC}"
    fi
done

echo -e "${GREEN}✅ Documentation and LICENSE files created!${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 FINALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 TRMS: The Race Management Solution - Setup Complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${WHITE}📁 Created Structure:${NC}"
echo -e "   ${GREEN}✅${NC} TRRS: The Race Registration Solution"
echo -e "   ${GREEN}✅${NC} TRTS: The Race Timing Solution (cloned from GitHub)"
echo -e "   ${GREEN}✅${NC} TRWS: The Race Web Solution (framework)"
echo -e "   ${GREEN}✅${NC} TRDS: The Race Data Solution (shared libraries)"
echo ""

echo -e "${WHITE}🚀 Quick Start:${NC}"
echo ""
echo -e "${YELLOW}1. Install Python dependencies:${NC}"
echo "   cd '$TRMS_BASE'"
echo "   pip install -r requirements.txt"
echo ""
echo -e "${YELLOW}2. Setup database (optional):${NC}"
echo "   cd 'TRDS: The Race Data Solution/scripts'"
echo "   ./setup_database.sh"
echo ""
echo -e "${YELLOW}3. Launch applications:${NC}"
echo "   ./trms_launcher.sh          # Master launcher"
echo "   ./run_trrs_console.sh       # Registration console"
echo "   ./run_trts_console.sh       # Timing console"
echo ""

echo -e "${WHITE}🔧 Configuration:${NC}"
echo -e "   ${CYAN}Environment variables:${NC}"
echo "   export TRMS_BASE='$TRMS_BASE'"
echo "   export USE_CLOUD_DB=true     # Optional: use cloud database"
echo "   export CLOUD_DB_HOST=your.cloud.host"
echo ""

echo -e "${WHITE}📚 Documentation:${NC}"
echo "   • README.md - Complete usage guide"
echo "   • requirements.txt - Python dependencies"
echo "   • Database schema in TRDS/sql/init/"
echo ""

echo -e "${GREEN}Ready to manage races with TRMS! 🏁${NC}"