#!/bin/bash

# ========================================
# Atlassian Enterprise User Manager
# Initial Setup Script
# ========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏢 Atlassian Enterprise User Manager Setup${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Please do not run this script as root${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Setup script ready!${NC}"
echo -e "${YELLOW}📋 Please run: chmod +x setup.sh && ./setup.sh${NC}"
