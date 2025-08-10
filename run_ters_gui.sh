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
