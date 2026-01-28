#!/bin/bash

# Tool Update Script

source src/config.sh

print_status "Updating BugBounty tools..." "info"

echo -e "${CYAN}[*] Updating system packages...${NC}"
if [ -d "/data/data/com.termux/files/usr" ]; then
    pkg update -y && pkg upgrade -y
else
    sudo apt update -y && sudo apt upgrade -y
fi

echo -e "${CYAN}[*] Updating Python packages...${NC}"
pip3 install --upgrade pip setuptools wheel 2>/dev/null
pip3 install --upgrade requests beautifulsoup4 lxml colorama scapy 2>/dev/null

echo -e "${CYAN}[*] Updating security tools...${NC}"

# Update Sublist3r
if [ -d "$TOOLS_DIR/Sublist3r" ]; then
    echo -e "${YELLOW}[*] Updating Sublist3r...${NC}"
    cd "$TOOLS_DIR/Sublist3r"
    git pull origin master 2>/dev/null
    cd - > /dev/null
    echo -e "${GREEN}[✓] Sublist3r updated${NC}"
fi

# Update dirsearch
if [ -d "$TOOLS_DIR/dirsearch" ]; then
    echo -e "${YELLOW}[*] Updating dirsearch...${NC}"
    cd "$TOOLS_DIR/dirsearch"
    git pull origin master 2>/dev/null
    cd - > /dev/null
    echo -e "${GREEN}[✓] dirsearch updated${NC}"
fi

# Update XSStrike
if [ -d "$TOOLS_DIR/XSStrike" ]; then
    echo -e "${YELLOW}[*] Updating XSStrike...${NC}"
    cd "$TOOLS_DIR/XSStrike"
    git pull origin master 2>/dev/null
    pip3 install -r requirements.txt --upgrade --quiet 2>/dev/null
    cd - > /dev/null
    echo -e "${GREEN}[✓] XSStrike updated${NC}"
fi

# Update sqlmap
if [ -d "$TOOLS_DIR/sqlmap" ]; then
    echo -e "${YELLOW}[*] Updating sqlmap...${NC}"
    cd "$TOOLS_DIR/sqlmap"
    git pull origin master 2>/dev/null
    cd - > /dev/null
    echo -e "${GREEN}[✓] sqlmap updated${NC}"
fi

# Update main script
echo -e "${YELLOW}[*] Checking for BugBounty updates...${NC}"
cd "$BASE_DIR"
if [ -d ".git" ]; then
    git pull origin main 2>/dev/null
    echo -e "${GREEN}[✓] BugBounty scripts updated${NC}"
else
    echo -e "${YELLOW}[!] Not a git repository, skipping update${NC}"
fi

echo -e "\n${GREEN}[✓] All tools updated successfully!${NC}"
echo -e "${CYAN}[*] Current version: v1.0${NC}"
