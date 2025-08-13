#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TRMS: The Race Management Solution - Master Launcher (Wayland Support)
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

# Detect display server
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo -e "${GREEN}🖥️  Display: Wayland ($WAYLAND_DISPLAY)${NC}"
elif [ -n "$DISPLAY" ]; then
    echo -e "${YELLOW}🖥️  Display: X11 ($DISPLAY)${NC}"
else
    echo -e "${RED}⚠️  Display: None detected${NC}"
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
echo "  2) 🖼️  GUI Application"
echo ""
echo -e "${BLUE}TRTS: The Race Timing Solution${NC}"
echo "  3) 🖥️  Console Application"
echo "  4) 🖼️  GUI Application"
echo ""
echo -e "${MAGENTA}System Utilities${NC}"
echo "  5) 🔧 Database Setup"
echo "  6) 📊 System Status"
echo "  7) 🌐 Launch Web Interface"
echo "  8) 🐳 Docker Management"
echo "  9) 🖼️  Launch GTK4 GUI Launcher"
echo ""
echo "  0) Exit"
echo ""

read -p "Enter selection [0-9]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Launching TRRS Console...${NC}"
        ./run_trrs_console.sh
        ;;
    2)
        echo -e "\n${GREEN}Launching TRRS GUI...${NC}"
        ./run_trrs_gui.sh
        ;;
    3)
        echo -e "\n${BLUE}Launching TRTS Console...${NC}"
        ./run_trts_console.sh
        ;;
    4)
        echo -e "\n${BLUE}Launching TRTS GUI...${NC}"
        ./run_trts_gui.sh
        ;;
    5)
        echo -e "\n${MAGENTA}Running Database Setup...${NC}"
        cd "TRDS: The Race Data Solution"
        if [ -f "scripts/setup_database.sh" ]; then
            ./scripts/setup_database.sh
        else
            echo "Database setup script not found"
        fi
        ;;
    6)
        echo -e "\n${MAGENTA}System Status${NC}"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo -e "TRMS Base: ${WHITE}$TRMS_BASE${NC}"
        echo -e "Python: ${WHITE}$(which $PYTHON_CMD)${NC}"
        echo -e "Environment: ${WHITE}${TRMS_ENV:-development}${NC}"
        
        # Display server info
        echo -e "\nDisplay Server:"
        if [ -n "$WAYLAND_DISPLAY" ]; then
            echo -e "  ${GREEN}✓ Wayland:${NC} $WAYLAND_DISPLAY"
            echo -e "  ${CYAN}  Socket:${NC} $XDG_RUNTIME_DIR/wayland-*"
        fi
        if [ -n "$DISPLAY" ]; then
            echo -e "  ${GREEN}✓ X11:${NC} $DISPLAY"
        fi
        if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
            echo -e "  ${RED}✗ No display server detected${NC}"
        fi
        
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
        echo -e "\n${MAGENTA}Launching Web Interface...${NC}"
        cd "TRWS: The Race Web Solution"
        if [ -f "scripts/start_web.sh" ]; then
            ./scripts/start_web.sh
        else
            echo "Web interface not yet configured"
            echo "Run the web setup script first"
        fi
        ;;
    8)
        echo -e "\n${MAGENTA}Docker Management${NC}"
        echo "1) Start Docker services"
        echo "2) Stop Docker services"  
        echo "3) View Docker status"
        echo "4) View logs"
        read -p "Select option: " docker_choice
        
        cd "TRDS: The Race Data Solution/docker"
        case $docker_choice in
            1) docker-compose up -d ;;
            2) docker-compose down ;;
            3) docker-compose ps ;;
            4) docker-compose logs -f ;;
        esac
        ;;
    9)
        echo -e "\n${GREEN}Launching GTK4 GUI Launcher...${NC}"
        if [ -n "$WAYLAND_DISPLAY" ]; then
            echo -e "${CYAN}Using Wayland backend${NC}"
            export GDK_BACKEND=wayland
        elif [ -n "$DISPLAY" ]; then
            echo -e "${CYAN}Using X11 backend${NC}"
            export GDK_BACKEND=x11
        fi
        ./trms_launcher_gui.py
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