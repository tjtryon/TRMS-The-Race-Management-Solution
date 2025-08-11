#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# 🗄️ TRMS Database Setup Script
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️ TRMS Database Setup${NC}"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRDS_DIR="$(dirname "$SCRIPT_DIR")"
SQL_DIR="$TRDS_DIR/sql/init"

# Database connection parameters
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-}"
DB_USER="${DB_USER:-trms}"
DB_PASSWORD="${DB_PASSWORD:-trms_password_2024}"
DB_NAME="${DB_NAME:-trms_db}"

echo -e "${YELLOW}Database Configuration:${NC}"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL client not found!${NC}"
    echo "Please install MySQL client:"
    echo "  Ubuntu/Debian: sudo apt install mysql-client"
    echo "  macOS: brew install mysql-client"
    exit 1
fi

# Test connection
echo -e "${YELLOW}🔍 Testing database connection...${NC}"
if [ -n "$DB_ROOT_PASSWORD" ]; then
    mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null
else
    mysql -h "$DB_HOST" -P "$DB_PORT" -u root -e "SELECT 1;" &>/dev/null
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Cannot connect to database${NC}"
    echo "Please check your database server and credentials."
    exit 1
fi

# Execute SQL files
echo -e "${YELLOW}📊 Creating database schema...${NC}"

for sql_file in "$SQL_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo -e "${BLUE}  Executing: $filename${NC}"
        
        if [ -n "$DB_ROOT_PASSWORD" ]; then
            mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_ROOT_PASSWORD" < "$sql_file"
        else
            mysql -h "$DB_HOST" -P "$DB_PORT" -u root < "$sql_file"
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}    ✅ Success${NC}"
        else
            echo -e "${RED}    ❌ Failed${NC}"
            exit 1
        fi
    fi
done

# Test the created database
echo -e "${YELLOW}🧪 Testing created database...${NC}"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" &>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database setup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Database ready for TRMS applications:${NC}"
    echo "  • TRRS: The Race Registration Solution"
    echo "  • TRTS: The Race Timing Solution"
    echo "  • TRWS: The Race Web Solution"
    echo ""
    echo -e "${YELLOW}Connection details:${NC}"
    echo "  Host: $DB_HOST"
    echo "  Database: $DB_NAME"
    echo "  User: $DB_USER"
    echo "  Password: $DB_PASSWORD"
else
    echo -e "${RED}❌ Database test failed${NC}"
    exit 1
fi
