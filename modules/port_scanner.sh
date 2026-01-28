#!/bin/bash

# Port Scanner Module

port_scan() {
    local target="$1"
    local result_dir="$2"
    
    echo -e "${CYAN}[*] Starting port scan for: $target${NC}"
    
    # Remove protocol if present
    target=$(echo "$target" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
    
    # Output files
    output_file="$result_dir/ports.txt"
    log_file="$result_dir/port_scan.log"
    
    {
        echo "Port Scan Report"
        echo "================"
        echo "Target: $target"
        echo "Date: $(date)"
        echo ""
        
        # Check if nmap is available
        if command -v nmap &> /dev/null; then
            echo "Method 1: Using nmap (quick scan)"
            echo "---------------------------------"
            
            # Quick scan top 100 ports
            nmap -T4 -F "$target" -oG "$result_dir/nmap_quick.txt" 2>/dev/null
            
            if [ -f "$result_dir/nmap_quick.txt" ]; then
                echo "Open ports found by nmap:"
                grep "/open/" "$result_dir/nmap_quick.txt" | \
                    awk '{print $2 " - Ports: " $4}' | \
                    sed 's/\/open\/tcp\///g' | sed 's/\/\/\//, /g'
            fi
            
            echo ""
            echo "Method 2: Service detection"
            echo "---------------------------"
            
            # Scan common ports with service detection
            common_ports="21,22,23,25,53,80,110,143,443,465,587,993,995,3306,3389,5432,8080,8443"
            nmap -sV -sC -p "$common_ports" "$target" -oN "$result_dir/nmap_services.txt" 2>/dev/null
            
            if [ -f "$result_dir/nmap_services.txt" ]; then
                echo "Services detected:"
                grep -E "(PORT|open)" "$result_dir/nmap_services.txt" | head -20
            fi
            
        else
            echo "Method 1: Basic TCP port scan"
            echo "-----------------------------"
            echo "Note: nmap not found, using basic socket connection"
            echo ""
            
            # Common ports to scan
            ports=(21 22 23 25 53 80 110 143 443 465 587 993 995 3306 3389 5432 8080 8443)
            
            echo "Port    Status   Service"
            echo "----    ------   -------"
            
            for port in "${ports[@]}"; do
                # Try to connect to port
                timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null
                if [ $? -eq 0 ]; then
                    # Get service name
                    case $port in
                        21) service="FTP" ;;
                        22) service="SSH" ;;
                        23) service="Telnet" ;;
                        25) service="SMTP" ;;
                        53) service="DNS" ;;
                        80) service="HTTP" ;;
                        110) service="POP3" ;;
                        143) service="IMAP" ;;
                        443) service="HTTPS" ;;
                        465) service="SMTPS" ;;
                        587) service="SMTP Submission" ;;
                        993) service="IMAPS" ;;
                        995) service="POP3S" ;;
                        3306) service="MySQL" ;;
                        3389) service="RDP" ;;
                        5432) service="PostgreSQL" ;;
                        8080) service="HTTP Proxy" ;;
                        8443) service="HTTPS Alt" ;;
                        *) service="Unknown" ;;
                    esac
                    
                    printf "%-8d %-8s %s\n" "$port" "OPEN" "$service"
                    echo "$port:OPEN:$service" >> "$output_file"
                fi
            done
        fi
        
        echo ""
        echo "Method 3: Check for web ports"
        echo "-----------------------------"
        
        web_ports=(80 443 8080 8443 8888 8000 8008 3000 5000)
        echo "Checking web ports..."
        
        for port in "${web_ports[@]}"; do
            if timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
                echo "[+] Web service on port $port"
                
                # Try to get HTTP headers
                if [ $port -eq 80 ] || [ $port -eq 8080 ] || [ $port -eq 8000 ] || [ $port -eq 8008 ]; then
                    curl -I "http://$target:$port" 2>/dev/null | head -5
                elif [ $port -eq 443 ] || [ $port -eq 8443 ] || [ $port -eq 8888 ]; then
                    curl -I -k "https://$target:$port" 2>/dev/null | head -5
                fi
                echo ""
            fi
        done
        
        echo ""
        echo "========================================"
        echo "SCAN SUMMARY"
        echo "========================================"
        
        if [ -f "$output_file" ] && [ -s "$output_file" ]; then
            total_ports=$(wc -l < "$output_file")
            echo "Total open ports found: $total_ports"
            echo ""
            echo "OPEN PORTS:"
            echo "-----------"
            cat "$output_file" | while read line; do
                port=$(echo "$line" | cut -d: -f1)
                service=$(echo "$line" | cut -d: -f3)
                echo "Port $port - $service"
            done
        else
            echo "No open ports found in common ports"
            echo "Note: This is a basic scan. Use nmap for comprehensive scanning."
        fi
        
        # Security recommendations
        echo ""
        echo "SECURITY RECOMMENDATIONS:"
        echo "-------------------------"
        if grep -q "22:OPEN:SSH" "$output_file" 2>/dev/null; then
            echo "• SSH (port 22) is open - Consider using key-based authentication"
        fi
        
        if grep -q "21:OPEN:FTP" "$output_file" 2>/dev/null; then
            echo "• FTP (port 21) is open - Consider using SFTP/FTPS instead"
        fi
        
        if grep -q "3389:OPEN:RDP" "$output_file" 2>/dev/null; then
            echo "• RDP (port 3389) is open - Use strong passwords and consider VPN"
        fi
        
    } | tee "$log_file"
    
    echo -e "\n${GREEN}[+] Port scan completed!${NC}"
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
        echo "Usage: $0 <target> [output_directory]"
        exit 1
    fi
    
    target="$1"
    result_dir="${2:-./portscan_$(date +%Y%m%d_%H%M%S)}"
    
    mkdir -p "$result_dir"
    port_scan "$target" "$result_dir"
fi
