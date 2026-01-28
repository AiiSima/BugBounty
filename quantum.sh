#!/bin/bash

# ============================================
# BugBounty - quantum v1.0
# Author: Sima
# Telegram: t.me/AiiSimaRajaIblis
# YouTube: @SimaV1-9
# Github: @AiiSima
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${CYAN}"
cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣸⣧⣀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣿⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣤⣿⡏⠉⣿⠀⠀⠀⠀⠀⠀⠀⣤⣼⠉⠉⢹⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⡾⠿⠀⠀⠀⣿⣷⣆⠀⠀⠀⣶⣾⣇⠀⠀⠀⢸⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣸⣿⣿⣇⣀⣀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣀⣼⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤
⠀⢰⣶⣶⣶⣶⣶⣶⡆⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣶⣾⣿⣿⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿
⣿⣿⣿⣿⠛⠛⠛⠛⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠉⠉⠉⠉⠀⠀⠀⠀⠀⠉⠉⠉⠉⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠉
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿ v1.0   
                        
                            BugBounty - quantum
                        telegram : t.me/AiiSimaRajaIblis 
                            YouTube  : @SimaV1-9 
                              Github : @AiiSima
EOF
echo -e "${NC}"

# Base directory
BASE_DIR=$(pwd)
export BASE_DIR

# Create directory structure
mkdir -p {src,modules,tools,reports,data/wordlists,logs,results,backups}

# Source configuration
if [ -f "src/config.sh" ]; then
    source src/config.sh
else
    echo -e "${RED}[!] Configuration file not found! Creating default...${NC}"
    
    # Create default config
    cat > src/config.sh << 'CONFIG'
#!/bin/bash
# Configuration for BugBounty

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

# Functions
print_status() {
    local message="$1"
    local status="${2:-info}"
    
    case $status in
        "success") echo -e "${GREEN}[✓] $message${NC}" ;;
        "error") echo -e "${RED}[✗] $message${NC}" ;;
        "info") echo -e "${CYAN}[*] $message${NC}" ;;
        "warning") echo -e "${YELLOW}[!] $message${NC}" ;;
        *) echo -e "${WHITE}[?] $message${NC}" ;;
    esac
}

validate_target() {
    local target="$1"
    if [ -z "$target" ]; then
        print_status "Target cannot be empty" "error"
        return 1
    fi
    return 0
}

log_message() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOGS_DIR/quantum.log"
}
CONFIG
    
    source src/config.sh
    print_status "Default configuration created" "success"
fi

# Main menu function
main_menu() {
    while true; do
        echo -e "\n${CYAN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║          BUG BOUNTY AUTOMATION MENU        ║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC} 1. ${GREEN}Target Reconnaissance${NC}              ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 2. ${GREEN}Vulnerability Scanner${NC}              ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 3. ${GREEN}Exploit Finder${NC}                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 4. ${GREEN}Full Automated Scan${NC}                ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 5. ${GREEN}Install/Update Tools${NC}               ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 6. ${GREEN}Generate Report${NC}                    ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 7. ${GREEN}Exit${NC}                               ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e ${YELLOW}"\n[?] Select option (1-7): "${NC})" choice
        
        case $choice in
            1)
                if [ -f "src/recon.sh" ]; then
                    source src/recon.sh
                    recon_menu
                else
                    echo -e "${RED}[!] Recon module not found${NC}"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "src/vuln_scanner.sh" ]; then
                    source src/vuln_scanner.sh
                    vuln_menu
                else
                    echo -e "${RED}[!] Vulnerability scanner module not found${NC}"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "src/exploit_finder.sh" ]; then
                    source src/exploit_finder.sh
                    exploit_menu
                else
                    echo -e "${RED}[!] Exploit finder module not found${NC}"
                    sleep 2
                fi
                ;;
            4)
                full_automated_scan
                ;;
            5)
                install_tools_menu
                ;;
            6)
                if [ -f "src/reporter.sh" ]; then
                    source src/reporter.sh
                    generate_report_menu
                else
                    echo -e "${RED}[!] Reporter module not found${NC}"
                    sleep 2
                fi
                ;;
            7)
                echo -e "${GREEN}[+] Thank you for using BugBounty - quantum!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Full automated scan function
full_automated_scan() {
    echo -e "${CYAN}[*] Starting Full Automated Scan${NC}"
    read -p "$(echo -e ${YELLOW}"[?] Enter target domain/IP: "${NC})" target
    
    if [ -z "$target" ]; then
        echo -e "${RED}[!] Target cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    # Create directory for results
    timestamp=$(date +"%Y%m%d_%H%M%S")
    clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
    result_dir="results/${clean_target}_${timestamp}"
    mkdir -p "$result_dir"
    
    echo -e "${GREEN}[+] Results will be saved in: $result_dir${NC}"
    
    # Run reconnaissance
    echo -e "${CYAN}[*] Starting Reconnaissance...${NC}"
    
    # Subdomain enumeration
    if [ -f "modules/subdomain_enum.sh" ]; then
        source modules/subdomain_enum.sh
        subdomain_enum "$target" "$result_dir"
    else
        echo -e "${YELLOW}[!] Subdomain module not found${NC}"
    fi
    
    # Port scanning
    echo -e "${CYAN}[*] Starting Port Scanning...${NC}"
    if [ -f "modules/port_scanner.sh" ]; then
        source modules/port_scanner.sh
        port_scan "$target" "$result_dir"
    else
        echo -e "${YELLOW}[!] Port scanner module not found${NC}"
    fi
    
    # Vulnerability scanning
    echo -e "${CYAN}[*] Starting Vulnerability Scanning...${NC}"
    if [ -f "modules/xss_scanner.sh" ]; then
        source modules/xss_scanner.sh
        xss_scan "$target" "$result_dir"
    fi
    
    if [ -f "modules/sqli_scanner.sh" ]; then
        source modules/sqli_scanner.sh
        sqli_scan "$target" "$result_dir"
    fi
    
    if [ -f "modules/lfi_scanner.sh" ]; then
        source modules/lfi_scanner.sh
        lfi_scan "$target" "$result_dir"
    fi
    
    # Generate report
    echo -e "${CYAN}[*] Generating Report...${NC}"
    if [ -f "src/reporter.sh" ]; then
        source src/reporter.sh
        generate_html_report "$target" "$result_dir"
        echo -e "${GREEN}[+] Report generated: $result_dir/report.html${NC}"
    fi
    
    echo -e "${GREEN}[+] Full scan completed!${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Tools installation menu
install_tools_menu() {
    while true; do
        clear
        echo -e "${CYAN}[*] Tools Installation Menu${NC}"
        echo -e "${CYAN}─────────────────────────────${NC}"
        echo -e "1. Install All Tools"
        echo -e "2. Update Tools"
        echo -e "3. Check Dependencies"
        echo -e "4. Back to Main Menu"
        
        read -p "$(echo -e ${YELLOW}"\n[?] Select option: "${NC})" choice
        
        case $choice in
            1)
                if [ -f "tools/install_tools.sh" ]; then
                    bash tools/install_tools.sh
                else
                    echo -e "${RED}[!] Install script not found${NC}"
                fi
                read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
                ;;
            2)
                if [ -f "tools/update_tools.sh" ]; then
                    bash tools/update_tools.sh
                else
                    echo -e "${RED}[!] Update script not found${NC}"
                fi
                read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
                ;;
            3)
                check_dependencies
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}[!] Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Check dependencies function
check_dependencies() {
    echo -e "${CYAN}[*] Checking Dependencies...${NC}"
    echo ""
    
    declare -A tools=(
        ["curl"]="curl"
        ["wget"]="wget"
        ["git"]="git"
        ["python3"]="python3"
        ["php"]="php"
    )
    
    missing_tools=()
    
    for tool in "${!tools[@]}"; do
        if command -v ${tools[$tool]} &> /dev/null; then
            version=$(${tools[$tool]} --version 2>/dev/null | head -1)
            echo -e "${GREEN}[✓] $tool: ${version:0:30}${NC}"
        else
            echo -e "${RED}[✗] $tool not installed${NC}"
            missing_tools+=("$tool")
        fi
    done
    
    echo ""
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${YELLOW}[!] Missing tools: ${missing_tools[*]}${NC}"
        read -p "$(echo -e ${YELLOW}"[?] Install missing tools? (y/n): "${NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -f "tools/install_tools.sh" ]; then
                bash tools/install_tools.sh
            else
                echo -e "${RED}[!] Install script not found${NC}"
            fi
        fi
    else
        echo -e "${GREEN}[✓] All dependencies are installed${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Start the main menu
main_menu
