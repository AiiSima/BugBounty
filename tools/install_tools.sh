#!/bin/bash

# Tool Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════╗
║         TOOL INSTALLATION SCRIPT          ║
╚════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running in Termux
check_termux() {
    if [ -d "/data/data/com.termux/files/usr" ]; then
        echo -e "${GREEN}[✓] Running in Termux${NC}"
        return 0
    else
        echo -e "${YELLOW}[*] Running in Linux${NC}"
        return 1
    fi
}

# Update package lists
update_packages() {
    echo -e "${CYAN}[*] Updating package lists...${NC}"
    
    if check_termux; then
        pkg update -y && pkg upgrade -y
    else
        sudo apt update -y && sudo apt upgrade -y
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Package lists updated${NC}"
    else
        echo -e "${RED}[✗] Failed to update packages${NC}"
    fi
}

# Install basic tools
install_basic_tools() {
    echo -e "${CYAN}[*] Installing basic tools...${NC}"
    
    basic_tools=("curl" "wget" "git" "python3" "php" "ruby" "perl")
    
    for tool in "${basic_tools[@]}"; do
        echo -e "${YELLOW}[*] Installing $tool...${NC}"
        
        if check_termux; then
            pkg install "$tool" -y 2>/dev/null
        else
            sudo apt install "$tool" -y 2>/dev/null
        fi
        
        if command -v "$tool" &> /dev/null; then
            echo -e "${GREEN}[✓] $tool installed successfully${NC}"
        else
            echo -e "${RED}[✗] Failed to install $tool${NC}"
        fi
    done
}

# Install security tools
install_security_tools() {
    echo -e "${CYAN}[*] Installing security tools...${NC}"
    
    sec_tools=("nmap" "whois" "dnsutils" "net-tools")
    
    for tool in "${sec_tools[@]}"; do
        echo -e "${YELLOW}[*] Installing $tool...${NC}"
        
        if check_termux; then
            pkg install "$tool" -y 2>/dev/null
        else
            sudo apt install "$tool" -y 2>/dev/null
        fi
        
        if command -v "$tool" &> /dev/null || [[ "$tool" == "dnsutils" ]]; then
            echo -e "${GREEN}[✓] $tool installed successfully${NC}"
        else
            echo -e "${YELLOW}[!] $tool might not be available${NC}"
        fi
    done
}

# Install Python packages
install_python_packages() {
    echo -e "${CYAN}[*] Installing Python packages...${NC}"
    
    if command -v pip3 &> /dev/null; then
        pip_packages=("requests" "beautifulsoup4" "lxml" "colorama")
        
        for package in "${pip_packages[@]}"; do
            echo -e "${YELLOW}[*] Installing $package...${NC}"
            pip3 install "$package" --quiet 2>/dev/null
            
            if pip3 show "$package" &> /dev/null; then
                echo -e "${GREEN}[✓] $package installed${NC}"
            else
                echo -e "${RED}[✗] Failed to install $package${NC}"
            fi
        done
    else
        echo -e "${YELLOW}[!] pip3 not found, installing...${NC}"
        if check_termux; then
            pkg install python-pip -y
        else
            sudo apt install python3-pip -y
        fi
        install_python_packages
    fi
}

# Download additional tools
download_tools() {
    echo -e "${CYAN}[*] Downloading additional tools...${NC}"
    
    # Create tools directory
    mkdir -p tools
    
    # Download Sublist3r
    echo -e "${YELLOW}[*] Downloading Sublist3r...${NC}"
    if [ ! -d "tools/Sublist3r" ]; then
        git clone https://github.com/aboul3la/Sublist3r.git tools/Sublist3r 2>/dev/null
        if [ -d "tools/Sublist3r" ]; then
            echo -e "${GREEN}[✓] Sublist3r downloaded${NC}"
        else
            echo -e "${RED}[✗] Failed to download Sublist3r${NC}"
        fi
    else
        echo -e "${GREEN}[✓] Sublist3r already exists${NC}"
    fi
    
    # Download dirsearch
    echo -e "${YELLOW}[*] Downloading dirsearch...${NC}"
    if [ ! -d "tools/dirsearch" ]; then
        git clone https://github.com/maurosoria/dirsearch.git tools/dirsearch 2>/dev/null
        if [ -d "tools/dirsearch" ]; then
            echo -e "${GREEN}[✓] dirsearch downloaded${NC}"
        else
            echo -e "${RED}[✗] Failed to download dirsearch${NC}"
        fi
    else
        echo -e "${GREEN}[✓] dirsearch already exists${NC}"
    fi
}

# Create wordlists
create_wordlists() {
    echo -e "${CYAN}[*] Creating wordlists...${NC}"
    
    mkdir -p data/wordlists
    
    # Subdomain wordlist
    cat > data/wordlists/subdomains.txt << 'EOF'
www
mail
ftp
admin
blog
api
test
dev
staging
portal
webmail
server
ns1
ns2
smtp
pop
imap
web
secure
vpn
docs
help
support
cloud
app
apps
beta
alpha
forum
wiki
shop
store
payment
billing
account
accounts
login
signin
auth
oauth
api2
api3
mobile
m
static
media
cdn
status
live
prod
production
stage
demo
EOF
    echo -e "${GREEN}[✓] Subdomain wordlist created${NC}"
    
    # Directory wordlist
    cat > data/wordlists/directories.txt << 'EOF'
admin
administrator
login
logout
signin
signout
register
dashboard
panel
cp
user
users
account
accounts
profile
settings
config
api
backup
test
dev
download
upload
files
images
css
js
assets
static
EOF
    echo -e "${GREEN}[✓] Directory wordlist created${NC}"
}

# Set permissions
set_permissions() {
    echo -e "${CYAN}[*] Setting permissions...${NC}"
    
    chmod +x quantum.sh 2>/dev/null
    chmod +x src/*.sh 2>/dev/null
    chmod +x modules/*.sh 2>/dev/null
    chmod +x tools/*.sh 2>/dev/null
    
    echo -e "${GREEN}[✓] Permissions set${NC}"
}

# Main installation process
main() {
    echo -e "${CYAN}[*] Starting installation process...${NC}"
    
    update_packages
    install_basic_tools
    install_security_tools
    install_python_packages
    download_tools
    create_wordlists
    set_permissions
    
    echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo -e ""
    echo -e "${CYAN}[*] Next steps:${NC}"
    echo -e "1. Run: ${GREEN}bash quantum.sh${NC}"
    echo -e "2. Select option 5 to check dependencies"
    echo -e "3. Start scanning targets"
    echo -e ""
    echo -e "${YELLOW}[!] Note: Some tools may need additional setup${NC}"
}

# Run main function
main
