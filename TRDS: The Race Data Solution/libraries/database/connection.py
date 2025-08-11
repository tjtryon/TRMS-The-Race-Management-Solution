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
