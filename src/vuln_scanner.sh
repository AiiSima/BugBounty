#!/bin/bash

# Vulnerability Scanner Module

source src/config.sh

# Vulnerability scanner menu
vuln_menu() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════╗
║        VULNERABILITY SCANNER MODULE       ║
╚════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      VULNERABILITY SCANNING OPTIONS        ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} 1. ${GREEN}XSS Scanner${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} 2. ${GREEN}SQL Injection Scanner${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} 3. ${GREEN}LFI/RFI Scanner${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} 4. ${GREEN}Full Vulnerability Scan${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} 5. ${GREEN}Back to Main Menu${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e ${YELLOW}"\n[?] Select option (1-5): "${NC})" choice
    
    case $choice in
        1)
            xss_scanner_menu
            ;;
        2)
            sqli_scanner_menu
            ;;
        3)
            lfi_scanner_menu
            ;;
        4)
            full_vuln_scan_menu
            ;;
        5)
            source quantum.sh
            main_menu
            ;;
        *)
            echo -e "${RED}[!] Invalid option!${NC}"
            sleep 1
            vuln_menu
            ;;
    esac
}

# XSS Scanner menu
xss_scanner_menu() {
    clear
    echo -e "${CYAN}[*] XSS Vulnerability Scanner${NC}"
    echo -e "${CYAN}──────────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target URL (with http/https): "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting XSS scan for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        target_name=$(echo "$target" | sed 's|https\?://||' | sed 's|/|_|g')
        result_dir="$RESULTS_DIR/${target_name}_xss_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run XSS scanner
        source modules/xss_scanner.sh
        xss_scan "$target" "$result_dir"
        
        echo -e "\n${GREEN}[+] XSS scan completed!${NC}"
        
        # Check if vulnerabilities were found
        if [ -f "$result_dir/xss_vulnerabilities.txt" ] && [ -s "$result_dir/xss_vulnerabilities.txt" ]; then
            echo -e "${RED}[!] XSS vulnerabilities found!${NC}"
            echo -e "${YELLOW}[*] Vulnerabilities saved in: $result_dir/xss_vulnerabilities.txt${NC}"
            
            # Display found vulnerabilities
            echo -e "\n${CYAN}[*] Found XSS Vulnerabilities:${NC}"
            echo -e "${CYAN}────────────────────────────────${NC}"
            cat "$result_dir/xss_vulnerabilities.txt"
        else
            echo -e "${GREEN}[✓] No XSS vulnerabilities found${NC}"
        fi
        
        echo -e "${GREEN}[+] Full results saved in: $result_dir${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})"
    vuln_menu
}

# SQL Injection Scanner menu
sqli_scanner_menu() {
    clear
    echo -e "${CYAN}[*] SQL Injection Scanner${NC}"
    echo -e "${CYAN}──────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target URL (with http/https): "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting SQL injection scan for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        target_name=$(echo "$target" | sed 's|https\?://||' | sed 's|/|_|g')
        result_dir="$RESULTS_DIR/${target_name}_sqli_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run SQLi scanner
        source modules/sqli_scanner.sh
        sqli_scan "$target" "$result_dir"
        
        echo -e "\n${GREEN}[+] SQL injection scan completed!${NC}"
        
        # Check if vulnerabilities were found
        if [ -f "$result_dir/sqli_vulnerabilities.txt" ] && [ -s "$result_dir/sqli_vulnerabilities.txt" ]; then
            echo -e "${RED}[!] SQL injection vulnerabilities found!${NC}"
            echo -e "${YELLOW}[*] Vulnerabilities saved in: $result_dir/sqli_vulnerabilities.txt${NC}"
            
            # Display found vulnerabilities
            echo -e "\n${CYAN}[*] Found SQL Injection Vulnerabilities:${NC}"
            echo -e "${CYAN}──────────────────────────────────────────${NC}"
            cat "$result_dir/sqli_vulnerabilities.txt" | head -10
        else
            echo -e "${GREEN}[✓] No SQL injection vulnerabilities found${NC}"
        fi
        
        echo -e "${GREEN}[+] Full results saved in: $result_dir${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})"
    vuln_menu
}

# LFI/RFI Scanner menu
lfi_scanner_menu() {
    clear
    echo -e "${CYAN}[*] LFI/RFI Vulnerability Scanner${NC}"
    echo -e "${CYAN}──────────────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target URL (with http/https): "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting LFI/RFI scan for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        target_name=$(echo "$target" | sed 's|https\?://||' | sed 's|/|_|g')
        result_dir="$RESULTS_DIR/${target_name}_lfi_${timestamp}"
        mkdir -p "$result_dir"
        
        # Run LFI scanner
        source modules/lfi_scanner.sh
        lfi_scan "$target" "$result_dir"
        
        echo -e "\n${GREEN}[+] LFI/RFI scan completed!${NC}"
        
        # Check if vulnerabilities were found
        if [ -f "$result_dir/lfi_vulnerabilities.txt" ] && [ -s "$result_dir/lfi_vulnerabilities.txt" ]; then
            echo -e "${RED}[!] LFI/RFI vulnerabilities found!${NC}"
            echo -e "${YELLOW}[*] Vulnerabilities saved in: $result_dir/lfi_vulnerabilities.txt${NC}"
            
            # Display found vulnerabilities
            echo -e "\n${CYAN}[*] Found LFI/RFI Vulnerabilities:${NC}"
            echo -e "${CYAN}────────────────────────────────────${NC}"
            cat "$result_dir/lfi_vulnerabilities.txt" | head -10
        else
            echo -e "${GREEN}[✓] No LFI/RFI vulnerabilities found${NC}"
        fi
        
        echo -e "${GREEN}[+] Full results saved in: $result_dir${NC}"
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})"
    vuln_menu
}

# Full vulnerability scan menu
full_vuln_scan_menu() {
    clear
    echo -e "${CYAN}[*] Full Vulnerability Scan${NC}"
    echo -e "${CYAN}───────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target URL (with http/https): "${NC})" target
    
    if validate_target "$target"; then
        print_status "Starting full vulnerability scan for: $target" "info"
        
        # Create results directory
        timestamp=$(date +"%Y%m%d_%H%M%S")
        target_name=$(echo "$target" | sed 's|https\?://||' | sed 's|/|_|g')
        result_dir="$RESULTS_DIR/${target_name}_full_vuln_${timestamp}"
        mkdir -p "$result_dir"
        
        echo -e "${GREEN}[+] Results will be saved in: $result_dir${NC}"
        
        # 1. XSS Scan
        echo -e "\n${CYAN}[1/3] Scanning for XSS vulnerabilities...${NC}"
        source modules/xss_scanner.sh
        xss_scan "$target" "$result_dir"
        echo -e "${GREEN}[✓] XSS scan completed${NC}"
        
        # 2. SQL Injection Scan
        echo -e "${CYAN}[2/3] Scanning for SQL injection vulnerabilities...${NC}"
        source modules/sqli_scanner.sh
        sqli_scan "$target" "$result_dir"
        echo -e "${GREEN}[✓] SQL injection scan completed${NC}"
        
        # 3. LFI/RFI Scan
        echo -e "${CYAN}[3/3] Scanning for LFI/RFI vulnerabilities...${NC}"
        source modules/lfi_scanner.sh
        lfi_scan "$target" "$result_dir"
        echo -e "${GREEN}[✓] LFI/RFI scan completed${NC}"
        
        echo -e "\n${GREEN}[+] Full vulnerability scan completed!${NC}"
        
        # Generate summary report
        generate_vuln_summary "$result_dir"
        
        echo -e "${GREEN}[+] Summary report: $result_dir/vulnerability_summary.txt${NC}"
        
        # Display summary
        if [ -f "$result_dir/vulnerability_summary.txt" ]; then
            echo -e "\n${CYAN}[*] Vulnerability Scan Summary:${NC}"
            echo -e "${CYAN}────────────────────────────────${NC}"
            cat "$result_dir/vulnerability_summary.txt"
        fi
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})"
    vuln_menu
}

# Function to generate vulnerability summary
generate_vuln_summary() {
    local result_dir="$1"
    local summary_file="$result_dir/vulnerability_summary.txt"
    
    {
        echo "VULNERABILITY SCAN SUMMARY"
        echo "=========================="
        echo "Scan Date: $(date)"
        echo "Target: $target"
        echo ""
        echo "XSS Vulnerabilities:"
        echo "-------------------"
        if [ -f "$result_dir/xss_vulnerabilities.txt" ] && [ -s "$result_dir/xss_vulnerabilities.txt" ]; then
            cat "$result_dir/xss_vulnerabilities.txt"
        else
            echo "None found"
        fi
        
        echo ""
        echo "SQL Injection Vulnerabilities:"
        echo "-----------------------------"
        if [ -f "$result_dir/sqli_vulnerabilities.txt" ] && [ -s "$result_dir/sqli_vulnerabilities.txt" ]; then
            cat "$result_dir/sqli_vulnerabilities.txt" | head -5
        else
            echo "None found"
        fi
        
        echo ""
        echo "LFI/RFI Vulnerabilities:"
        echo "-----------------------"
        if [ -f "$result_dir/lfi_vulnerabilities.txt" ] && [ -s "$result_dir/lfi_vulnerabilities.txt" ]; then
            cat "$result_dir/lfi_vulnerabilities.txt" | head -5
        else
            echo "None found"
        fi
        
        echo ""
        echo "SCAN COMPLETED"
        echo "=============="
    } > "$summary_file"
}
