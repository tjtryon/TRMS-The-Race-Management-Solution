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
