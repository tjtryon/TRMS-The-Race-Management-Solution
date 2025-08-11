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
