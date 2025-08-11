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
