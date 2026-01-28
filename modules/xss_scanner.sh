#!/bin/bash

# XSS Scanner Module

source src/config.sh

# Function to scan for XSS vulnerabilities
xss_scan() {
    local target="$1"
    local result_dir="$2"
    
    print_status "Starting XSS scan for: $target" "info"
    
    # Create output files
    output_file="$result_dir/xss_results.txt"
    vuln_file="$result_dir/xss_vulnerabilities.txt"
    
    {
        echo "XSS Scan Results for: $target"
        echo "Generated on: $(date)"
        echo "="*60
        echo ""
        
        # Check if target is a URL
        if [[ ! $target =~ ^https?:// ]]; then
            target="http://$target"
        fi
        
        echo "METHOD 1: Basic XSS payload testing"
        echo "-----------------------------------"
        
        # Common XSS payloads
        payloads=(
            "<script>alert('XSS')</script>"
            "\"><script>alert('XSS')</script>"
            "'><script>alert('XSS')</script>"
            "<img src=x onerror=alert('XSS')>"
            "<svg onload=alert('XSS')>"
            "javascript:alert('XSS')"
            "<body onload=alert('XSS')>"
            "<iframe src=\"javascript:alert('XSS')\">"
        )
        
        # Test URL parameters
        echo "Testing URL parameters..." | tee -a "$output_file"
        
        # Extract URL without parameters
        base_url=$(echo "$target" | cut -d'?' -f1)
        query_string=$(echo "$target" | cut -d'?' -f2)
        
        if [ ! -z "$query_string" ]; then
            IFS='&' read -ra params <<< "$query_string"
            
            for param in "${params[@]}"; do
                param_name=$(echo "$param" | cut -d'=' -f1)
                echo "  Testing parameter: $param_name" | tee -a "$output_file"
                
                for payload in "${payloads[@]}"; do
                    test_url="${base_url}?${param_name}=${payload}"
                    
                    # Send request and check response
                    response=$(curl -s -L "$test_url" 2>/dev/null)
                    
                    if echo "$response" | grep -q "$payload"; then
                        echo "    [!] VULNERABLE: $param_name with payload: $payload" | tee -a "$output_file"
                        echo "URL: $test_url" >> "$vuln_file"
                    fi
                done
            done
        else
            echo "  No URL parameters found" | tee -a "$output_file"
        fi
        
        echo ""
        echo "METHOD 2: Form testing"
        echo "----------------------"
        
        # Try to find forms
        echo "Looking for forms..." | tee -a "$output_file"
        
        # Download page
        page_content=$(curl -s "$target")
        
        # Extract forms
        forms=$(echo "$page_content" | grep -i "<form")
        
        if [ ! -z "$forms" ]; then
            echo "  Forms found:" | tee -a "$output_file"
            echo "$forms" | tee -a "$output_file"
        else
            echo "  No forms found" | tee -a "$output_file"
        fi
        
        echo ""
        echo "METHOD 3: Using XSStrike (if available)"
        echo "----------------------------------------"
        
        if [ -f "$TOOLS_DIR/XSStrike/xsstrike.py" ]; then
            echo "Running XSStrike..." | tee -a "$output_file"
            python3 "$TOOLS_DIR/XSStrike/xsstrike.py" -u "$target" --skip > "$result_dir/xsstrike.txt" 2>&1
            
            if [ -f "$result_dir/xsstrike.txt" ]; then
                grep -i "vulnerable\|payload" "$result_dir/xsstrike.txt" | head -10 | tee -a "$output_file"
            fi
        else
            echo "XSStrike not found. Skipping..." | tee -a "$output_file"
        fi
        
        echo ""
        echo "="*60
        echo "SCAN SUMMARY"
        echo "="*60
        
        if [ -f "$vuln_file" ] && [ -s "$vuln_file" ]; then
            echo "[!] XSS VULNERABILITIES FOUND!" | tee -a "$output_file"
            echo "Check $vuln_file for details" | tee -a "$output_file"
            echo "" | tee -a "$output_file"
            echo "Vulnerable URLs:" | tee -a "$output_file"
            cat "$vuln_file" | tee -a "$output_file"
        else
            echo "[✓] No XSS vulnerabilities detected" | tee -a "$output_file"
            echo "Note: This is a basic scan. Manual testing recommended." | tee -a "$output_file"
        fi
        
    } > "$result_dir/xss_scan.log"
    
    # Display results
    if [ -f "$vuln_file" ] && [ -s "$vuln_file" ]; then
        echo -e "\n${RED}[!] XSS vulnerabilities found!${NC}"
        echo -e "${CYAN}[*] Vulnerable URLs:${NC}"
        cat "$vuln_file"
    else
        echo -e "\n${GREEN}[✓] No XSS vulnerabilities found${NC}"
    fi
}

# Main execution if script called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <target_url> [output_dir]"
        exit 1
    fi
    
    target="$1"
    result_dir="${2:-$RESULTS_DIR/${target}_$(date +%Y%m%d_%H%M%S)}"
    
    mkdir -p "$result_dir"
    xss_scan "$target" "$result_dir"
fi
