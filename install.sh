#!/bin/bash

# Installation script for BugBounty - quantum

echo -e "\033[1;36m"
echo "╔════════════════════════════════════════════╗"
echo "║       BugBounty - quantum Installer       ║"
echo "╚════════════════════════════════════════════╝"
echo -e "\033[0m"

# Check if running in Termux
if [ -d "/data/data/com.termux/files/usr" ]; then
    echo -e "\033[1;32m[✓] Detected Termux environment\033[0m"
    IS_TERMUX=true
else
    echo -e "\033[1;33m[*] Detected Linux environment\033[0m"
    IS_TERMUX=false
fi

# Update packages
echo -e "\n\033[1;36m[*] Updating package lists...\033[0m"
if [ "$IS_TERMUX" = true ]; then
    pkg update -y && pkg upgrade -y
else
    sudo apt update -y && sudo apt upgrade -y
fi

# Install dependencies
echo -e "\n\033[1;36m[*] Installing dependencies...\033[0m"

dependencies=("git" "curl" "wget" "python3" "php" "nmap" "whois")

for dep in "${dependencies[@]}"; do
    echo -e "\033[1;33m[*] Installing $dep...\033[0m"
    
    if [ "$IS_TERMUX" = true ]; then
        pkg install "$dep" -y 2>/dev/null
    else
        sudo apt install "$dep" -y 2>/dev/null
    fi
    
    if command -v "$dep" &> /dev/null || [[ "$dep" == "whois" && -f /usr/bin/whois ]]; then
        echo -e "\033[1;32m[✓] $dep installed\033[0m"
    else
        echo -e "\033[1;31m[✗] $dep installation failed (may already be installed)\033[0m"
    fi
done

# Install Python packages
echo -e "\n\033[1;36m[*] Installing Python packages...\033[0m"
if command -v pip3 &> /dev/null; then
    pip3 install requests beautifulsoup4 lxml colorama --quiet
    echo -e "\033[1;32m[✓] Python packages installed\033[0m"
else
    echo -e "\033[1;33m[*] Installing pip3...\033[0m"
    if [ "$IS_TERMUX" = true ]; then
        pkg install python-pip -y
    else
        sudo apt install python3-pip -y
    fi
    pip3 install requests beautifulsoup4 lxml colorama --quiet
fi

# Create directory structure
echo -e "\n\033[1;36m[*] Creating directory structure...\033[0m"
mkdir -p {src,modules,tools,reports,data/wordlists,logs,results,backups}

# Download the main script and modules
echo -e "\n\033[1;36m[*] Downloading BugBounty scripts...\033[0m"

# Create quantum.sh
cat > quantum.sh << 'EOF'
#!/bin/bash

# ============================================
# BugBounty - quantum v1.0
# Main Script
# ============================================

# [CONTENT OF quantum.sh FROM ABOVE - PASTE THE ENTIRE SCRIPT HERE]
EOF

# Make scripts executable
chmod +x quantum.sh

# Create all other necessary files
echo -e "\033[1;33m[*] Setting up configuration files...\033[0m"

# Create minimal working versions of all required files
# [You would create all the other script files here as shown above]

echo -e "\n\033[1;32m════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m[✓] Installation completed successfully!\033[0m"
echo -e "\033[1;32m════════════════════════════════════════════\033[0m"
echo -e "\n\033[1;36m[*] To start using BugBounty:\033[0m"
echo -e "    \033[1;33mbash quantum.sh\033[0m"
echo -e "\n\033[1;36m[*] First time setup:\033[0m"
echo -e "    1. Run the tool"
echo -e "    2. Select option 5 (Install/Update Tools)"
echo -e "    3. Select option 1 (Install All Tools)"
echo -e "\n\033[1;36m[*] Need help?\033[0m"
echo -e "    Telegram: t.me/AiiSimaRajaIblis"
echo -e "    GitHub: @AiiSima"
