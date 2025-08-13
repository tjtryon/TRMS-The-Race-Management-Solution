#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🖼️ TRRS GUI Launcher - Wayland Prioritized
# ═══════════════════════════════════════════════════════════════════════════════

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🖼️ Starting TRRS: The Race Registration Solution (GUI)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"

# Detect if we're in Docker
if [ -f /.dockerenv ]; then
    echo -e "${CYAN}🐳 Running in Docker environment${NC}"
    PYTHON_CMD="python3"
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

# Configure display - Prioritize Wayland
echo -e "${CYAN}Checking display server...${NC}"

if [ -n "$WAYLAND_DISPLAY" ]; then
    echo -e "${GREEN}✅ Wayland display found: $WAYLAND_DISPLAY${NC}"
    export GDK_BACKEND=wayland
    echo -e "${CYAN}   Using Wayland backend${NC}"
elif [ -n "$DISPLAY" ]; then
    echo -e "${GREEN}✅ X11 display found: $DISPLAY${NC}"
    # Let GTK auto-detect the best backend
    unset GDK_BACKEND
    echo -e "${CYAN}   GTK will auto-detect backend${NC}"
else
    echo -e "${YELLOW}⚠️  No display detected${NC}"
    
    # Try to detect Wayland socket
    if [ -S "${XDG_RUNTIME_DIR}/wayland-0" ]; then
        echo -e "${CYAN}   Found Wayland socket, attempting Wayland...${NC}"
        export WAYLAND_DISPLAY=wayland-0
        export GDK_BACKEND=wayland
    elif [ -S "/run/user/$(id -u)/wayland-0" ]; then
        echo -e "${CYAN}   Found Wayland socket in /run/user, attempting Wayland...${NC}"
        export WAYLAND_DISPLAY=wayland-0
        export GDK_BACKEND=wayland
    else
        echo -e "${YELLOW}   No Wayland socket found, falling back to X11${NC}"
        export DISPLAY=:0
        unset GDK_BACKEND
    fi
fi

# Show GTK debug info if requested
if [ "$GTK_DEBUG" = "1" ]; then
    echo -e "${CYAN}GTK Debug Info:${NC}"
    echo "  GDK_BACKEND=${GDK_BACKEND:-auto}"
    echo "  WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
    echo "  DISPLAY=$DISPLAY"
    echo "  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    echo "  XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
fi

# Navigate to TRRS directory
cd "TRRS: The Race Registration Solution/gui" 2>/dev/null || \
cd "TRRS: The Race Registration Solution" 2>/dev/null || {
    echo -e "${RED}❌ TRRS directory not found!${NC}"
    exit 1
}

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Launching TRRS GUI with ${GDK_BACKEND:-auto} backend${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"

# Check if the GUI file exists
if [ -f "race_registration_gui.py" ]; then
    $PYTHON_CMD race_registration_gui.py
else
    echo -e "${YELLOW}⚠️  TRRS GUI implementation not complete${NC}"
    echo -e "${CYAN}The TRRS GUI is currently a placeholder.${NC}"
    echo -e "${CYAN}For now, please use:${NC}"
    echo -e "  ${GREEN}• TRRS Console:${NC} ./run_trrs_console.sh"
    echo -e "  ${GREEN}• GTK4 Launcher:${NC} ./trms_launcher_gui.py"
    echo ""
    echo -e "${CYAN}Creating simple GTK4 placeholder...${NC}"
    
    # Create a simple placeholder
    cat > /tmp/trrs_gui_temp.py << 'EOF'
#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw

class TRRSPlaceholder(Adw.Application):
    def __init__(self):
        super().__init__(application_id='com.trrs.placeholder')
        
    def do_activate(self):
        window = Adw.ApplicationWindow(application=self)
        window.set_title("TRRS GUI - Coming Soon")
        window.set_default_size(500, 300)
        
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        window.set_content(box)
        
        header = Adw.HeaderBar()
        box.append(header)
        
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        content.set_margin_top(50)
        content.set_margin_bottom(50)
        content.set_margin_start(50)
        content.set_margin_end(50)
        box.append(content)
        
        label = Gtk.Label()
        label.set_markup("<big><b>🏁 TRRS GUI Coming Soon</b></big>")
        content.append(label)
        
        info = Gtk.Label()
        info.set_text("The TRRS GUI is under development.\nPlease use the console version or the GTK4 launcher.")
        content.append(info)
        
        # Show backend info
        backend = Gtk.Label()
        import os
        gdk_backend = os.environ.get('GDK_BACKEND', 'auto')
        if os.environ.get('WAYLAND_DISPLAY'):
            backend.set_markup(f"<small>Running on Wayland ({os.environ.get('WAYLAND_DISPLAY')})</small>")
        elif os.environ.get('DISPLAY'):
            backend.set_markup(f"<small>Running on X11 ({os.environ.get('DISPLAY')})</small>")
        else:
            backend.set_markup(f"<small>Display server: {gdk_backend}</small>")
        content.append(backend)
        
        button = Gtk.Button(label="Close")
        button.connect("clicked", lambda x: self.quit())
        content.append(button)
        
        window.present()

app = TRRSPlaceholder()
app.run()
EOF
    
    $PYTHON_CMD /tmp/trrs_gui_temp.py
fi