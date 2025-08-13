#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🖼️ TRTS GUI Launcher
# ═══════════════════════════════════════════════════════════════════════════════

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🖼️ Starting TRTS: The Race Timing Solution (GUI)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"

# Detect if we're in Docker
if [ -f /.dockerenv ]; then
    echo -e "${CYAN}🐳 Running in Docker environment${NC}"
    PYTHON_CMD="python3"
    
    # Check for display in Docker
    if [ -z "$DISPLAY" ]; then
        echo -e "${YELLOW}⚠️  Warning: No display detected in Docker${NC}"
        echo -e "${YELLOW}   Make sure X11 forwarding is enabled${NC}"
        echo -e "${YELLOW}   You may need to run: xhost +local:docker${NC}"
    fi
else
    echo -e "${CYAN}💻 Running in local environment${NC}"
    
    # Check for virtual environment
    if [ -d "venv" ]; then
        echo -e "${GREEN}🐍 Activating virtual environment...${NC}"
        source venv/bin/activate
        PYTHON_CMD="python"
    elif [ -d ".venv" ]; then
        echo -e "${GREEN}🐍 Activating virtual environment...${NC}"
        source .venv/bin/activate
        PYTHON_CMD="python"
    else
        PYTHON_CMD="python3"
    fi
fi

# Set environment variables
export TRMS_BASE="$(pwd)"
export TRMS_ENV="${TRMS_ENV:-development}"

# Check for display
if [ -z "$DISPLAY" ]; then
    echo -e "${YELLOW}⚠️  Warning: No display detected. Setting DISPLAY=:0${NC}"
    export DISPLAY=:0
else
    echo -e "${GREEN}✅ Display found: $DISPLAY${NC}"
fi

# Check if TRTS directory exists
TRTS_DIR="TRTS: The Race Timing Solution"
if [ ! -d "$TRTS_DIR" ]; then
    echo -e "${RED}❌ Error: TRTS directory not found!${NC}"
    echo -e "${YELLOW}Please ensure TRTS is installed:${NC}"
    echo -e "${CYAN}git clone https://github.com/tjtryon/TRTS-The-Race-Timing-Solution.git \"$TRTS_DIR\"${NC}"
    exit 1
fi

echo -e "${GREEN}✅ TRTS directory found${NC}"
cd "$TRTS_DIR"

# Check for GTK dependencies
echo -e "${CYAN}Checking GTK4 dependencies...${NC}"
$PYTHON_CMD -c "import gi; gi.require_version('Gtk', '4.0'); from gi.repository import Gtk" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  GTK4 may not be available${NC}"
    echo -e "${YELLOW}   Attempting to run anyway...${NC}"
fi

# Look for TRTS GUI files in different possible locations
GUI_FILES=(
    "race_timing_gui.py"
    "gui/race_timing_gui.py"
    "src/race_timing_gui.py"
    "src/gui/race_timing_gui.py"
    "trts_gui.py"
    "main_gui.py"
)

GUI_FOUND=""
for file in "${GUI_FILES[@]}"; do
    if [ -f "$file" ]; then
        GUI_FOUND="$file"
        echo -e "${GREEN}✅ Found GUI file: $file${NC}"
        break
    fi
done

# If no GUI file found, check if it's a GTK3 app that needs updating
if [ -z "$GUI_FOUND" ]; then
    echo -e "${YELLOW}⚠️  No GTK4 GUI file found${NC}"
    echo -e "${CYAN}Checking for GTK3 GUI files...${NC}"
    
    # Look for GTK3 files
    GTK3_FILES=(
        "race_timing_gui_gtk3.py"
        "gui_gtk3.py"
    )
    
    for file in "${GTK3_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${YELLOW}Found GTK3 file: $file${NC}"
            echo -e "${YELLOW}Note: TRTS may be using GTK3. Running with GTK3...${NC}"
            GUI_FOUND="$file"
            break
        fi
    done
fi

# If still no GUI found, create a placeholder
if [ -z "$GUI_FOUND" ]; then
    echo -e "${YELLOW}⚠️  TRTS GUI application not found${NC}"
    echo -e "${CYAN}Creating placeholder GUI...${NC}"
    
    cat > trts_gui_placeholder.py << 'EOF'
#!/usr/bin/env python3
"""TRTS GUI Placeholder"""

print("="*60)
print("⏱️ TRTS: The Race Timing Solution")
print("="*60)
print()
print("GUI application not found in the TRTS repository.")
print()
print("This could mean:")
print("1. TRTS GUI is still in development")
print("2. The GUI file is in a different location")
print("3. You need to update TRTS from GitHub")
print()
print("To update TRTS:")
print("  cd 'TRTS: The Race Timing Solution'")
print("  git pull")
print()
print("For now, you can use:")
print("  - TRTS Console: ./run_trts_console.sh")
print("  - TRRS Applications for registration")
print()

# Try to create a simple GTK window as placeholder
try:
    import gi
    gi.require_version('Gtk', '4.0')
    gi.require_version('Adw', '1')
    from gi.repository import Gtk, Adw
    
    class PlaceholderApp(Adw.Application):
        def __init__(self):
            super().__init__(application_id='com.trts.placeholder')
            
        def do_activate(self):
            window = Adw.ApplicationWindow(application=self)
            window.set_title("TRTS GUI - Not Available")
            window.set_default_size(400, 200)
            
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            window.set_content(box)
            
            header = Adw.HeaderBar()
            box.append(header)
            
            label = Gtk.Label()
            label.set_markup("<big><b>⏱️ TRTS GUI Not Found</b></big>\n\n" +
                           "Please check the TRTS repository\n" +
                           "or use the console version")
            label.set_vexpand(True)
            box.append(label)
            
            window.present()
    
    app = PlaceholderApp()
    app.run()
    
except ImportError:
    print("GTK4 not available for placeholder GUI")
EOF
    
    GUI_FOUND="trts_gui_placeholder.py"
    chmod +x "$GUI_FOUND"
fi

# Run the GUI
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Launching TRTS GUI: $GUI_FOUND${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"

$PYTHON_CMD "$GUI_FOUND"

# Check exit code
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ TRTS GUI exited successfully${NC}"
else
    echo -e "${RED}❌ TRTS GUI exited with error${NC}"
    echo -e "${YELLOW}Try running TRTS Console instead: ./run_trts_console.sh${NC}"
fi