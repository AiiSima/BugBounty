#!/bin/bash

# Configuration file for BugBounty - quantum

# Version
VERSION="1.0"
AUTHOR="Sima"
TELEGRAM="t.me/AiiSimaRajaIblis"
GITHUB="github.com/AiiSima"

# Directories
BASE_DIR=$(pwd)
SRC_DIR="$BASE_DIR/src"
MODULES_DIR="$BASE_DIR/modules"
TOOLS_DIR="$BASE_DIR/tools"
REPORTS_DIR="$BASE_DIR/reports"
DATA_DIR="$BASE_DIR/data"
WORDLISTS_DIR="$DATA_DIR/wordlists"
LOGS_DIR="$BASE_DIR/logs"
RESULTS_DIR="$BASE_DIR/results"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# API Keys (Add your own API keys here)
# SHODAN_API="sk_9a8b7c6d5e4f3g2h1i0j9k8l7m6n5o4p3q2r1s0"
# VIRUSTOTAL_API="e0d1c2b3a4f5e6d7c8b9a0f1e2d3c4b5a6f7e8d9c0"
# CENSYS_API_ID="a1b2c3d4-e5f6-7890-abcd-ef1234567890"
# CENSYS_API_SECRET="c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1"

# Tool Paths
NMAP_PATH=$(which nmap 2>/dev/null)
SQLMAP_PATH=$(which sqlmap 2>/dev/null)
SUBLIST3R_PATH="$TOOLS_DIR/Sublist3r/sublist3r.py"
DIRSEARCH_PATH="$TOOLS_DIR/dirsearch/dirsearch.py"
XSSTRIKE_PATH="$TOOLS_DIR/XSStrike/xsstrike.py"
NIKTO_PATH=$(which nikto 2>/dev/null)

# Logging
LOG_FILE="$LOGS_DIR/quantum.log"
DEBUG_LOG="$LOGS_DIR/debug.log"

# Function to log messages
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# Function to debug log
debug_log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $message" >> "$DEBUG_LOG"
}

# Function to print status
print_status() {
    local message="$1"
    local status="$2"
    
    case $status in
        "success")
            echo -e "${GREEN}[✓] $message${NC}"
            ;;
        "error")
            echo -e "${RED}[✗] $message${NC}"
            ;;
        "info")
            echo -e "${CYAN}[*] $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}[!] $message${NC}"
            ;;
        *)
            echo -e "${WHITE}[?] $message${NC}"
            ;;
    esac
}

# Function to validate target
validate_target() {
    local target="$1"
    
    # Check if target is not empty
    if [ -z "$target" ]; then
        print_status "Target cannot be empty" "error"
        return 1
    fi
    
    # Basic URL validation
    if [[ $target =~ ^https?:// ]] || [[ $target =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || [[ $target =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_status "Target validated: $target" "success"
        return 0
    else
        print_status "Invalid target format" "error"
        return 1
    fi
}

# Function to create directory structure
create_directories() {
    mkdir -p "$SRC_DIR"
    mkdir -p "$MODULES_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$DATA_DIR"
    mkdir -p "$WORDLISTS_DIR"
    mkdir -p "$LOGS_DIR"
    mkdir -p "$RESULTS_DIR"
}

# Initialize
create_directories
