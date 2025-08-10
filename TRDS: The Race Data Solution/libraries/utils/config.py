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
