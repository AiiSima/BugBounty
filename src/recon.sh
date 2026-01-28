#!/bin/bash

# Reconnaissance Module

source src/config.sh

# Submenu untuk reconnaissance
recon_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        cat << "EOF"
╔════════════════════════════════════════════╗
║         RECONNAISSANCE MODULE             ║
╚════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        
        echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         RECONNAISSANCE OPTIONS             ║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC} 1. ${GREEN}Subdomain Enumeration${NC}                 ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 2. ${GREEN}Port Scanning${NC}                         ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 3. ${GREEN}Web Crawling${NC}                          ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 4. ${GREEN}WHOIS Lookup${NC}                          ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 5. ${GREEN}DNS Information${NC}                       ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 6. ${GREEN}Full Reconnaissance${NC}                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 7. ${GREEN}Back to Main Menu${NC}                     ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e ${YELLOW}"\n[?] Select option (1-7): "${NC})" choice
        
        case $choice in
            1)
                subdomain_menu
                ;;
            2)
                port_scan_menu
                ;;
            3)
                web_crawl_menu
                ;;
            4)
                whois_lookup_menu
                ;;
            5)
                dns_info_menu
                ;;
            6)
                full_recon_menu
                ;;
            7)
                return
                ;;
            *)
                echo -e "${RED}[!] Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Subdomain enumeration
subdomain_menu() {
    clear
    echo -e "${CYAN}[*] Subdomain Enumeration${NC}"
    echo -e "${CYAN}──────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target domain: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting subdomain enumeration for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_subdomains_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run subdomain enumeration
        if [ -f "modules/subdomain_enum.sh" ]; then
            source modules/subdomain_enum.sh
            subdomain_enum "$target" "$result_dir"
        else
            echo -e "${RED}[!] Subdomain module not found${NC}"
            echo -e "${YELLOW}[*] Creating basic subdomain scan...${NC}"
            
            # Basic subdomain check
            {
                echo "Basic Subdomain Scan for: $target"
                echo "Generated: $(date)"
                echo ""
                echo "Common subdomains:"
                echo "------------------"
                
                common_subs=("www" "mail" "ftp" "admin" "blog" "api" "test" "dev" "staging" "portal")
                
                for sub in "${common_subs[@]}"; do
                    full_domain="${sub}.${target}"
                    if ping -c 1 -W 1 "$full_domain" &> /dev/null || \
                       nslookup "$full_domain" 2>/dev/null | grep -q "Address"; then
                        echo "[+] $full_domain"
                    fi
                done
            } > "$result_dir/subdomains.txt"
            
            cat "$result_dir/subdomains.txt"
        fi
        
        echo -e "\n${GREEN}[+] Subdomain enumeration completed!${NC}"
        echo -e "${GREEN}[+] Results saved in: $result_dir/subdomains.txt${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Port scanning
port_scan_menu() {
    clear
    echo -e "${CYAN}[*] Port Scanning${NC}"
    echo -e "${CYAN}──────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target IP/domain: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting port scan for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_ports_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run port scanning
        if [ -f "modules/port_scanner.sh" ]; then
            source modules/port_scanner.sh
            port_scan "$target" "$result_dir"
        else
            echo -e "${RED}[!] Port scanner module not found${NC}"
            echo -e "${YELLOW}[*] Creating basic port scan...${NC}"
            
            # Basic port scan
            {
                echo "Basic Port Scan for: $target"
                echo "Generated: $(date)"
                echo ""
                echo "Common ports scan:"
                echo "------------------"
                
                common_ports=(21 22 23 25 53 80 110 143 443 465 587 993 995 3306 3389 8080 8443)
                
                for port in "${common_ports[@]}"; do
                    timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null
                    if [ $? -eq 0 ]; then
                        echo "[+] Port $port: OPEN"
                    fi
                done
            } > "$result_dir/ports.txt"
            
            cat "$result_dir/ports.txt"
        fi
        
        echo -e "\n${GREEN}[+] Port scanning completed!${NC}"
        echo -e "${GREEN}[+] Results saved in: $result_dir/ports.txt${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Web crawling
web_crawl_menu() {
    clear
    echo -e "${CYAN}[*] Web Crawling${NC}"
    echo -e "${CYAN}────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target URL: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting web crawling for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_webcrawl_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run web crawling
        if [ -f "modules/web_crawler.sh" ]; then
            source modules/web_crawler.sh
            web_crawl "$target" "$result_dir"
        else
            echo -e "${RED}[!] Web crawler module not found${NC}"
            echo -e "${YELLOW}[*] Creating basic web crawl...${NC}"
            
            # Basic web crawl
            {
                echo "Basic Web Crawl for: $target"
                echo "Generated: $(date)"
                echo ""
                echo "Fetching page content..."
                echo "-----------------------"
                
                # Try to get page with curl
                curl -s -L "$target" 2>/dev/null | \
                    grep -E "(href|src)=" | \
                    grep -o '"[^"]*"' | \
                    tr -d '"' | \
                    sort -u | head -20
            } > "$result_dir/crawl_results.txt"
            
            if [ -s "$result_dir/crawl_results.txt" ]; then
                cat "$result_dir/crawl_results.txt"
            else
                echo "No links found or failed to fetch page"
            fi
        fi
        
        echo -e "\n${GREEN}[+] Web crawling completed!${NC}"
        echo -e "${GREEN}[+] Results saved in: $result_dir/crawl_results.txt${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# WHOIS lookup
whois_lookup_menu() {
    clear
    echo -e "${CYAN}[*] WHOIS Lookup${NC}"
    echo -e "${CYAN}────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target domain: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Performing WHOIS lookup for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_whois_${timestamp}"
        mkdir -p "$result_dir"
        
        # Perform WHOIS lookup
        if command -v whois &> /dev/null; then
            whois "$target" > "$result_dir/whois.txt" 2>&1
            echo -e "${GREEN}[+] WHOIS information saved to: $result_dir/whois.txt${NC}"
            
            # Display relevant information
            echo -e "\n${CYAN}[*] WHOIS Information for $target:${NC}"
            echo -e "${CYAN}─────────────────────────────────${NC}"
            
            # Try to extract useful info
            if [ -f "$result_dir/whois.txt" ]; then
                grep -E "(Registrant|Admin|Tech|Name Server|Creation Date|Expiration Date|Updated Date|Domain Name|Registrar)" \
                    "$result_dir/whois.txt" | head -10 || \
                    head -20 "$result_dir/whois.txt"
            fi
        else
            echo -e "${RED}[!] WHOIS command not found${NC}"
            echo -e "${YELLOW}[*] Attempting to install whois...${NC}"
            
            if [ -d "/data/data/com.termux/files/usr" ]; then
                pkg install whois -y 2>/dev/null
            else
                sudo apt install whois -y 2>/dev/null
            fi
            
            if command -v whois &> /dev/null; then
                whois "$target" > "$result_dir/whois.txt" 2>&1
                head -20 "$result_dir/whois.txt"
            else
                echo "Failed to install whois. Manual lookup recommended."
            fi
        fi
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# DNS information
dns_info_menu() {
    clear
    echo -e "${CYAN}[*] DNS Information${NC}"
    echo -e "${CYAN}───────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target domain: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Gathering DNS information for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_dns_${timestamp}"
        mkdir -p "$result_dir"
        
        # Gather DNS information
        echo -e "\n${CYAN}[*] DNS Records for $target:${NC}"
        echo -e "${CYAN}────────────────────────────${NC}"
        
        {
            echo "DNS Records for: $target"
            echo "Generated: $(date)"
            echo ""
            
            # Check different record types
            record_types=("A" "AAAA" "MX" "TXT" "NS" "CNAME" "SOA")
            
            for record in "${record_types[@]}"; do
                echo "=== $record Records ==="
                dig "$target" $record +short 2>/dev/null || nslookup -type=$record "$target" 2>/dev/null | tail -n +4
                echo ""
            done
        } > "$result_dir/dns_info.txt"
        
        cat "$result_dir/dns_info.txt"
        
        echo -e "\n${GREEN}[+] DNS information saved to: $result_dir/dns_info.txt${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Full reconnaissance
full_recon_menu() {
    clear
    echo -e "${CYAN}[*] Full Reconnaissance${NC}"
    echo -e "${CYAN}───────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target domain: "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting full reconnaissance for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        clean_target=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
        result_dir="$RESULTS_DIR/${clean_target}_full_recon_${timestamp}"
        mkdir -p "$result_dir"
        
        echo -e "${GREEN}[+] Results will be saved in: $result_dir${NC}"
        
        # 1. WHOIS Lookup
        echo -e "\n${CYAN}[1/5] Performing WHOIS lookup...${NC}"
        if command -v whois &> /dev/null; then
            whois "$target" > "$result_dir/whois.txt" 2>/dev/null
            echo -e "${GREEN}[✓] WHOIS completed${NC}"
        fi
        
        # 2. DNS Information
        echo -e "${CYAN}[2/5] Gathering DNS information...${NC}"
        {
            echo "DNS Records for: $target"
            echo ""
            echo "A Records:"
            dig "$target" A +short 2>/dev/null || echo "Not found"
            echo ""
            echo "MX Records:"
            dig "$target" MX +short 2>/dev/null || echo "Not found"
            echo ""
            echo "NS Records:"
            dig "$target" NS +short 2>/dev/null || echo "Not found"
            echo ""
            echo "TXT Records:"
            dig "$target" TXT +short 2>/dev/null || echo "Not found"
        } > "$result_dir/dns_info.txt"
        echo -e "${GREEN}[✓] DNS information gathered${NC}"
        
        # 3. Subdomain Enumeration
        echo -e "${CYAN}[3/5] Enumerating subdomains...${NC}"
        if [ -f "modules/subdomain_enum.sh" ]; then
            source modules/subdomain_enum.sh
            subdomain_enum "$target" "$result_dir"
        else
            # Basic subdomain check
            {
                echo "Basic Subdomain Scan"
                echo "===================="
                common_subs=("www" "mail" "ftp" "admin" "blog" "api")
                for sub in "${common_subs[@]}"; do
                    echo "Checking ${sub}.${target}..."
                done
            } > "$result_dir/subdomains.txt"
        fi
        echo -e "${GREEN}[✓] Subdomain enumeration completed${NC}"
        
        # 4. Port Scanning
        echo -e "${CYAN}[4/5] Scanning ports...${NC}"
        if [ -f "modules/port_scanner.sh" ]; then
            source modules/port_scanner.sh
            port_scan "$target" "$result_dir"
        else
            # Basic port scan
            {
                echo "Common Ports Scan"
                echo "================="
                ports=(21 22 80 443 3306 3389)
                for port in "${ports[@]}"; do
                    timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && \
                    echo "Port $port: OPEN" || true
                done
            } > "$result_dir/ports.txt"
        fi
        echo -e "${GREEN}[✓] Port scanning completed${NC}"
        
        # 5. Web Crawling
        echo -e "${CYAN}[5/5] Crawling website...${NC}"
        if [ -f "modules/web_crawler.sh" ]; then
            source modules/web_crawler.sh
            web_crawl "http://$target" "$result_dir"
        else
            # Basic web crawl
            {
                echo "Basic Web Crawl"
                echo "==============="
                curl -s -L "http://$target" 2>/dev/null | \
                    grep -o 'href="[^"]*"' | \
                    cut -d'"' -f2 | \
                    head -10
            } > "$result_dir/web_crawl.txt"
        fi
        echo -e "${GREEN}[✓] Web crawling completed${NC}"
        
        echo -e "\n${GREEN}[+] Full reconnaissance completed!${NC}"
        echo -e "${GREEN}[+] All results saved in: $result_dir${NC}"
        
        # Show summary
        echo -e "\n${CYAN}[*] Reconnaissance Summary:${NC}"
        echo -e "${CYAN}────────────────────────────${NC}"
        ls -la "$result_dir"/*.txt | awk '{print "• " $9}'
        
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}
