#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 TRMS: The Race Management Solution - Master Launcher
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
echo "  2) 🖼️  GUI Application (Coming Soon)"
echo ""
echo -e "${BLUE}TRTS: The Race Timing Solution${NC}"
echo "  3) 🖥️  Console Application"
echo "  4) 🖼️  GUI Application"
echo ""
echo -e "${MAGENTA}System Utilities${NC}"
echo "  5) 🔧 Database Setup"
echo "  6) 📊 System Status"
echo "  7) 🌐 Launch Web Interface (Coming Soon)"
echo "  8) 🐳 Docker Management"
echo ""
echo "  0) Exit"
echo ""

read -p "Enter selection [0-8]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Launching TRRS Console...${NC}"
        ./run_trrs_console.sh
        ;;
    2)
        echo -e "\n${GREEN}TRRS GUI coming soon!${NC}"
        echo "For now, please use the console application."
        ;;
    3)
        echo -e "\n${BLUE}Launching TRTS Console...${NC}"
        ./run_trts_console.sh
        ;;
    4)
        echo -e "\n${BLUE}Launching TRTS GUI...${NC}"
        cd "TRTS: The Race Timing Solution"
        if [ -f "race_timing_gui.py" ]; then
            $PYTHON_CMD race_timing_gui.py
        else
            echo "TRTS GUI not found in expected location"
        fi
        ;;
    5)
        echo -e "\n${MAGENTA}Database Setup${NC}"
        echo "Creating database schema..."
        # Database setup will be implemented
        ;;
    6)
        echo -e "\n${MAGENTA}System Status${NC}"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo -e "TRMS Base: ${WHITE}$TRMS_BASE${NC}"
        echo -e "Python: ${WHITE}$(which $PYTHON_CMD)${NC}"
        echo -e "Environment: ${WHITE}${TRMS_ENV:-development}${NC}"
        
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
        echo -e "\n${MAGENTA}Web Interface coming soon!${NC}"
        echo "TRWS: The Race Web Solution will provide unified web access."
        ;;
    8)
        if [ "$DOCKER_AVAILABLE" = "true" ]; then
            echo -e "\n${MAGENTA}Docker Management${NC}"
            echo "1) Start Docker services"
            echo "2) Stop Docker services"  
            echo "3) View Docker status"
            echo "4) View logs"
            read -p "Select option: " docker_choice
            
            case $docker_choice in
                1) echo "Docker services starting..." ;;
                2) echo "Docker services stopping..." ;;
                3) echo "Docker status..." ;;
                4) echo "Docker logs..." ;;
            esac
        else
            echo -e "\n${RED}Docker not available${NC}"
        fi
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
