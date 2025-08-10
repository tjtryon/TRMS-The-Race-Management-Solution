run#!/bin/bash

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
