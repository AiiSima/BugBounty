#!/bin/bash

# Subdomain Enumeration Module

subdomain_enum() {
    local target="$1"
    local result_dir="$2"
    
    echo -e "${CYAN}[*] Starting subdomain enumeration for: $target${NC}"
    
    # Remove protocol if present
    target=$(echo "$target" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
    
    # Output files
    output_file="$result_dir/subdomains.txt"
    log_file="$result_dir/subdomain_enum.log"
    
    {
        echo "Subdomain Enumeration Report"
        echo "============================"
        echo "Target: $target"
        echo "Date: $(date)"
        echo ""
        
        echo "Method 1: Common Subdomains Check"
        echo "---------------------------------"
        
        # List of common subdomains
        common_subs=(
            "www" "mail" "ftp" "admin" "blog" "api" "test" "dev" 
            "staging" "portal" "webmail" "server" "ns1" "ns2"
            "smtp" "pop" "imap" "web" "secure" "vpn" "docs"
            "help" "support" "cloud" "app" "apps" "beta" "alpha"
            "forum" "wiki" "shop" "store" "payment" "billing"
            "account" "accounts" "login" "signin" "auth" "oauth"
            "api2" "api3" "mobile" "m" "static" "media" "cdn"
            "status" "live" "prod" "production" "stage" "demo"
        )
        
        found_count=0
        for sub in "${common_subs[@]}"; do
            full_domain="${sub}.${target}"
            
            # Try multiple methods to check if subdomain exists
            if ping -c 1 -W 1 "$full_domain" &> /dev/null; then
                echo "[+] $full_domain (ping success)"
                echo "$full_domain" >> "$output_file"
                ((found_count++))
            elif nslookup "$full_domain" 2>/dev/null | grep -q "Address"; then
                echo "[+] $full_domain (DNS record found)"
                echo "$full_domain" >> "$output_file"
                ((found_count++))
            elif host "$full_domain" 2>/dev/null | grep -q "has address"; then
                echo "[+] $full_domain (host command)"
                echo "$full_domain" >> "$output_file"
                ((found_count++))
            fi
        done
        
        echo ""
        echo "Method 2: Using curl for discovery"
        echo "----------------------------------"
        
        # Try to get subdomains from SSL certificate
        if command -v curl &> /dev/null; then
            echo "Checking SSL certificate for subdomains..."
            curl -v "https://$target" 2>&1 | \
                grep -o "subjectAltName:.*" | \
                grep -o "DNS:[^,]*" | \
                cut -d: -f2 | \
                sort -u >> "$output_file.tmp" 2>/dev/null
            
            if [ -f "$output_file.tmp" ] && [ -s "$output_file.tmp" ]; then
                echo "Found in SSL certificate:"
                cat "$output_file.tmp"
                cat "$output_file.tmp" >> "$output_file"
                rm "$output_file.tmp"
            fi
        fi
        
        echo ""
        echo "Method 3: Brute force with wordlist"
        echo "-----------------------------------"
        
        # Create temporary wordlist if not exists
        wordlist_file="/tmp/subdomain_wordlist.txt"
        if [ ! -f "$wordlist_file" ] || [ ! -s "$wordlist_file" ]; then
            echo "Creating wordlist..."
            cat > "$wordlist_file" << 'EOF'
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
        fi
        
        echo "Using wordlist: $wordlist_file"
        echo "Scanning..."
        
        brute_count=0
        while read -r sub; do
            full_domain="${sub}.${target}"
            
            # Check with host command (faster)
            if host "$full_domain" 2>/dev/null | grep -q "has address"; then
                echo "[+] $full_domain"
                echo "$full_domain" >> "$output_file"
                ((brute_count++))
            fi
        done < "$wordlist_file"
        
        echo ""
        echo "========================================"
        echo "SCAN SUMMARY"
        echo "========================================"
        echo "Total common subdomains checked: ${#common_subs[@]}"
        echo "Common subdomains found: $found_count"
        echo "Brute force subdomains found: $brute_count"
        
        # Remove duplicates and sort
        if [ -f "$output_file" ]; then
            sort -u "$output_file" -o "$output_file"
            total_found=$(wc -l < "$output_file")
            echo "Total unique subdomains found: $total_found"
            
            echo ""
            echo "FOUND SUBDOMAINS:"
            echo "-----------------"
            cat "$output_file"
        else
            echo "No subdomains found"
            touch "$output_file"
        fi
        
    } | tee "$log_file"
    
    echo -e "\n${GREEN}[+] Subdomain enumeration completed!${NC}"
    echo -e "${GREEN}[+] Results saved in: $output_file${NC}"
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Colors for standalone execution
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <target_domain> [output_directory]"
        exit 1
    fi
    
    target="$1"
    result_dir="${2:-./results_$(date +%Y%m%d_%H%M%S)}"
    
    mkdir -p "$result_dir"
    subdomain_enum "$target" "$result_dir"
fi
