#!/bin/bash

# Reporter Module

source src/config.sh

# Generate report menu
generate_report_menu() {
    while true; do
        clear
        echo -e "${CYAN}"
        cat << "EOF"
╔════════════════════════════════════════════╗
║           REPORT GENERATOR MODULE          ║
╚════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        
        echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║           REPORT GENERATION OPTIONS        ║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC} 1. ${GREEN}Generate HTML Report${NC}                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 2. ${GREEN}Generate Text Report${NC}                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 3. ${GREEN}Generate Markdown Report${NC}               ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC} 4. ${GREEN}Back to Main Menu${NC}                      ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
        
        read -p "$(echo -e ${YELLOW}"\n[?] Select option (1-4): "${NC})" choice
        
        case $choice in
            1)
                generate_html_report_menu
                ;;
            2)
                generate_text_report_menu
                ;;
            3)
                generate_markdown_report_menu
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

# Generate HTML report menu
generate_html_report_menu() {
    clear
    echo -e "${CYAN}[*] Generate HTML Report${NC}"
    echo -e "${CYAN}────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target name: "${NC})" target_name
    
    if [ -z "$target_name" ]; then
        echo -e "${RED}[!] Target name cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    # Ask for results directory
    echo -e "${YELLOW}[*] Available result directories:${NC}"
    ls -d results/*/ 2>/dev/null | head -10 || echo "No results found"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter scan results directory: "${NC})" results_dir
    
    if [ ! -d "$results_dir" ]; then
        echo -e "${RED}[!] Results directory not found!${NC}"
        echo -e "${YELLOW}[*] Creating new directory...${NC}"
        results_dir="results/${target_name}_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$results_dir"
    fi
    
    print_status "Generating HTML report for: $target_name" "info"
    
    # Generate HTML report
    generate_html_report "$target_name" "$results_dir"
    
    echo -e "\n${GREEN}[+] HTML report generated successfully!${NC}"
    echo -e "${GREEN}[+] Report saved as: $results_dir/report.html${NC}"
    
    # Check if we can open the report
    if command -v termux-open &> /dev/null; then
        read -p "$(echo -e ${YELLOW}"[?] Open report in browser? (y/n): "${NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            termux-open "$results_dir/report.html"
        fi
    fi
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Generate HTML report
generate_html_report() {
    local target_name="$1"
    local results_dir="$2"
    local report_file="$results_dir/report.html"
    
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Create HTML report
    cat > "$report_file" << HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BugBounty Report - $target_name</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        
        .header .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
            margin-top: 10px;
        }
        
        .section {
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .section h2 {
            color: #4a5568;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
            margin-top: 0;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .info-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .info-card h3 {
            margin-top: 0;
            color: #2d3748;
        }
        
        .vulnerability {
            background: #fff5f5;
            border-left: 4px solid #fc8181;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
        }
        
        .finding {
            background: #e6fffa;
            border-left: 4px solid #38b2ac;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
        }
        
        .timestamp {
            background: #edf2f7;
            padding: 10px;
            border-radius: 5px;
            font-family: monospace;
            margin: 10px 0;
        }
        
        pre {
            background: #2d3748;
            color: #e2e8f0;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
        }
        
        .severity-high {
            color: #c53030;
            font-weight: bold;
        }
        
        .severity-medium {
            color: #dd6b20;
            font-weight: bold;
        }
        
        .severity-low {
            color: #38a169;
            font-weight: bold;
        }
        
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
            color: #718096;
            font-size: 0.9em;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }
        
        th {
            background-color: #edf2f7;
            font-weight: bold;
        }
        
        tr:hover {
            background-color: #f7fafc;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>BugBounty Security Report</h1>
        <div class="subtitle">Target: $target_name</div>
        <div class="timestamp">Report Generated: $current_date</div>
    </div>
    
    <div class="section">
        <h2>Executive Summary</h2>
        <div class="info-grid">
            <div class="info-card">
                <h3>Target Information</h3>
                <p><strong>Target:</strong> $target_name</p>
                <p><strong>Report Date:</strong> $current_date</p>
                <p><strong>Scanner:</strong> BugBounty - quantum</p>
            </div>
            
            <div class="info-card">
                <h3>Scan Overview</h3>
                <p><strong>Scan Type:</strong> Security Assessment</p>
                <p><strong>Scope:</strong> Web Application</p>
                <p><strong>Methodology:</strong> Automated Scanning</p>
            </div>
            
            <div class="info-card">
                <h3>Risk Assessment</h3>
                <p><strong>Overall Risk:</strong> <span id="risk-level">Medium</span></p>
                <p><strong>Findings:</strong> <span id="findings-count">Multiple</span></p>
                <p><strong>Status:</strong> Requires Review</p>
            </div>
        </div>
    </div>
HTML
    
    # Add findings from files
    add_findings_section "$target_name" "$results_dir" "$report_file"
    
    # Add recommendations
    cat >> "$report_file" << HTML
    <div class="section">
        <h2>Recommendations</h2>
        <div class="finding">
            <h3>Immediate Actions</h3>
            <ul>
                <li>Review all identified vulnerabilities</li>
                <li>Implement proper input validation</li>
                <li>Update and patch all software components</li>
                <li>Implement Web Application Firewall (WAF)</li>
            </ul>
        </div>
        
        <div class="finding">
            <h3>Security Best Practices</h3>
            <ul>
                <li>Regular security audits and penetration testing</li>
                <li>Implement security headers (CSP, HSTS, etc.)</li>
                <li>Use parameterized queries for database access</li>
                <li>Implement proper logging and monitoring</li>
                <li>Regular security awareness training for staff</li>
            </ul>
        </div>
    </div>
    
    <div class="section">
        <h2>Technical Details</h2>
        <table>
            <tr>
                <th>Scan Type</th>
                <th>Date</th>
                <th>Files</th>
                <th>Status</th>
            </tr>
HTML
    
    # List scan files
    for file in "$results_dir"/*.txt; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            filedate=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1) || filedate="N/A"
            filesize=$(du -h "$file" 2>/dev/null | cut -f1) || filesize="N/A"
            
            cat >> "$report_file" << HTML
            <tr>
                <td>$filename</td>
                <td>$filedate</td>
                <td>$filesize</td>
                <td>Completed</td>
            </tr>
HTML
        fi
    done
    
    cat >> "$report_file" << HTML
        </table>
    </div>
    
    <div class="section">
        <h2>Appendix</h2>
        <div class="info-card">
            <h3>Tools Used</h3>
            <ul>
                <li>BugBounty - quantum v1.0</li>
                <li>Custom reconnaissance scripts</li>
                <li>Automated vulnerability scanners</li>
            </ul>
        </div>
        
        <div class="info-card">
            <h3>References</h3>
            <ul>
                <li>OWASP Testing Guide</li>
                <li>Penetration Testing Execution Standard</li>
                <li>NIST Cybersecurity Framework</li>
            </ul>
        </div>
    </div>
    
    <div class="footer">
        <p>Generated by BugBounty - quantum | Author: Sima</p>
        <p>Telegram: t.me/AiiSimaRajaIblis | GitHub: @AiiSima</p>
        <p>This report is confidential and intended only for authorized personnel.</p>
    </div>
    
    <script>
        // Simple JavaScript for interactivity
        document.addEventListener('DOMContentLoaded', function() {
            // Count findings
            const findings = document.querySelectorAll('.vulnerability, .finding');
            document.getElementById('findings-count').textContent = findings.length + ' findings';
            
            // Set risk level based on findings
            const riskLevel = findings.length > 5 ? 'High' : findings.length > 2 ? 'Medium' : 'Low';
            document.getElementById('risk-level').textContent = riskLevel;
            document.getElementById('risk-level').className = 'severity-' + riskLevel.toLowerCase();
            
            // Add click handlers to sections
            document.querySelectorAll('.section h2').forEach(header => {
                header.addEventListener('click', function() {
                    this.parentElement.classList.toggle('collapsed');
                });
            });
        });
    </script>
</body>
</html>
HTML
    
    echo -e "${GREEN}[✓] HTML report created successfully${NC}"
}

# Add findings section
add_findings_section() {
    local target_name="$1"
    local results_dir="$2"
    local report_file="$3"
    
    cat >> "$report_file" << HTML
    <div class="section">
        <h2>Findings</h2>
HTML
    
    # Check for subdomains
    if [ -f "$results_dir/subdomains.txt" ] && [ -s "$results_dir/subdomains.txt" ]; then
        subdomain_count=$(wc -l < "$results_dir/subdomains.txt")
        cat >> "$report_file" << HTML
        <div class="finding">
            <h3>Subdomain Enumeration</h3>
            <p><strong>Status:</strong> <span class="severity-medium">$subdomain_count subdomains found</span></p>
            <pre>
HTML
        head -10 "$results_dir/subdomains.txt" >> "$report_file"
        cat >> "$report_file" << HTML
            </pre>
        </div>
HTML
    fi
    
    # Check for open ports
    if [ -f "$results_dir/ports.txt" ] && [ -s "$results_dir/ports.txt" ]; then
        cat >> "$report_file" << HTML
        <div class="finding">
            <h3>Open Ports</h3>
            <pre>
HTML
        cat "$results_dir/ports.txt" >> "$report_file"
        cat >> "$report_file" << HTML
            </pre>
        </div>
HTML
    fi
    
    # Check for vulnerabilities
    check_vulnerability_files "$results_dir" "$report_file"
    
    cat >> "$report_file" << HTML
    </div>
HTML
}

# Check for vulnerability files
check_vulnerability_files() {
    local results_dir="$1"
    local report_file="$2"
    
    vuln_files=("xss_vulnerabilities.txt" "sqli_vulnerabilities.txt" "lfi_vulnerabilities.txt")
    
    for vuln_file in "${vuln_files[@]}"; do
        if [ -f "$results_dir/$vuln_file" ] && [ -s "$results_dir/$vuln_file" ]; then
            vuln_type=$(echo "$vuln_file" | sed 's/_vulnerabilities\.txt//' | tr '[:lower:]' '[:upper:]')
            vuln_count=$(wc -l < "$results_dir/$vuln_file")
            
            cat >> "$report_file" << HTML
        <div class="vulnerability">
            <h3>$vuln_type Vulnerabilities Found</h3>
            <p><strong>Severity:</strong> <span class="severity-high">HIGH</span></p>
            <p><strong>Count:</strong> $vuln_count potential vulnerabilities</p>
            <p><strong>File:</strong> $vuln_file</p>
        </div>
HTML
        fi
    done
}

# Generate text report menu
generate_text_report_menu() {
    clear
    echo -e "${CYAN}[*] Generate Text Report${NC}"
    echo -e "${CYAN}───────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target name: "${NC})" target_name
    
    if [ -z "$target_name" ]; then
        echo -e "${RED}[!] Target name cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    echo -e "${YELLOW}[*] Available result directories:${NC}"
    ls -d results/*/ 2>/dev/null | head -10 || echo "No results found"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter scan results directory: "${NC})" results_dir
    
    if [ ! -d "$results_dir" ]; then
        echo -e "${RED}[!] Results directory not found!${NC}"
        sleep 2
        return
    fi
    
    print_status "Generating text report for: $target_name" "info"
    
    generate_text_report "$target_name" "$results_dir"
    
    echo -e "\n${GREEN}[+] Text report generated successfully!${NC}"
    echo -e "${GREEN}[+] Report saved as: $results_dir/report.txt${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Generate text report
generate_text_report() {
    local target_name="$1"
    local results_dir="$2"
    local report_file="$results_dir/report.txt"
    
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    cat > "$report_file" << TXT
==================================================
              BUG BOUNTY REPORT
==================================================

Target: $target_name
Date: $current_date
Generated by: BugBounty - quantum

==================================================
EXECUTIVE SUMMARY
==================================================

This report summarizes the security assessment of 
$target_name conducted using automated scanning tools.

Assessment Scope:
- Subdomain enumeration
- Port scanning
- Vulnerability detection
- Web application testing

==================================================
FINDINGS
==================================================

TXT
    
    # Add subdomains
    if [ -f "$results_dir/subdomains.txt" ] && [ -s "$results_dir/subdomains.txt" ]; then
        subdomain_count=$(wc -l < "$results_dir/subdomains.txt")
        cat >> "$report_file" << TXT
[+] SUBDOMAIN ENUMERATION
-------------------------
Subdomains found: $subdomain_count

$(head -20 "$results_dir/subdomains.txt")

TXT
    fi
    
    # Add port scan results
    if [ -f "$results_dir/ports.txt" ] && [ -s "$results_dir/ports.txt" ]; then
        cat >> "$report_file" << TXT
[+] PORT SCAN RESULTS
----------------------
$(cat "$results_dir/ports.txt")

TXT
    fi
    
    # Add vulnerabilities
    cat >> "$report_file" << TXT
[+] VULNERABILITY ASSESSMENT
----------------------------
TXT
    
    vuln_files=("xss_vulnerabilities.txt" "sqli_vulnerabilities.txt" "lfi_vulnerabilities.txt")
    found_vulns=0
    
    for vuln_file in "${vuln_files[@]}"; do
        if [ -f "$results_dir/$vuln_file" ] && [ -s "$results_dir/$vuln_file" ]; then
            vuln_type=$(echo "$vuln_file" | sed 's/_vulnerabilities\.txt//' | tr '[:lower:]' '[:upper:]')
            vuln_count=$(wc -l < "$results_dir/$vuln_file")
            cat >> "$report_file" << TXT
- $vuln_type: $vuln_count potential vulnerabilities found
TXT
            ((found_vulns++))
        fi
    done
    
    if [ $found_vulns -eq 0 ]; then
        cat >> "$report_file" << TXT
- No critical vulnerabilities detected in automated scan

TXT
    fi
    
    cat >> "$report_file" << TXT

==================================================
RECOMMENDATIONS
==================================================

1. Immediate Actions:
   • Review all scan findings
   • Patch identified vulnerabilities
   • Implement security monitoring

2. Security Improvements:
   • Regular security audits
   • Implement WAF
   • Security awareness training
   • Update and patch regularly

3. Long-term Strategy:
   • Implement SDLC security
   • Continuous security testing
   • Incident response planning

==================================================
APPENDIX
==================================================

Scan Files:
TXT
    
    for file in "$results_dir"/*.txt; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            filesize=$(du -h "$file" 2>/dev/null | cut -f1) || filesize="N/A"
            cat >> "$report_file" << TXT
- $filename ($filesize)

TXT
        fi
    done
    
    cat >> "$report_file" << TXT
==================================================
END OF REPORT
==================================================

Generated on: $current_date
Confidential - For authorized personnel only
TXT
}

# Generate markdown report menu
generate_markdown_report_menu() {
    clear
    echo -e "${CYAN}[*] Generate Markdown Report${NC}"
    echo -e "${CYAN}───────────────────────────${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter target name: "${NC})" target_name
    
    if [ -z "$target_name" ]; then
        echo -e "${RED}[!] Target name cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    echo -e "${YELLOW}[*] Available result directories:${NC}"
    ls -d results/*/ 2>/dev/null | head -10 || echo "No results found"
    
    read -p "$(echo -e ${YELLOW}"[?] Enter scan results directory: "${NC})" results_dir
    
    if [ ! -d "$results_dir" ]; then
        echo -e "${RED}[!] Results directory not found!${NC}"
        sleep 2
        return
    fi
    
    print_status "Generating markdown report for: $target_name" "info"
    
    generate_markdown_report "$target_name" "$results_dir"
    
    echo -e "\n${GREEN}[+] Markdown report generated successfully!${NC}"
    echo -e "${GREEN}[+] Report saved as: $results_dir/report.md${NC}"
    
    read -p "$(echo -e ${YELLOW}"[?] Press Enter to continue..."${NC})" dummy
}

# Generate markdown report
generate_markdown_report() {
    local target_name="$1"
    local results_dir="$2"
    local report_file="$results_dir/report.md"
    
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    cat > "$report_file" << MD
# BugBounty Security Report

## Target Information
- **Target**: $target_name
- **Date**: $current_date
- **Generated by**: BugBounty - quantum
- **Report Type**: Security Assessment

## Executive Summary

Security assessment of \`$target_name\` conducted using automated scanning tools. This report includes findings from reconnaissance and vulnerability scanning activities.

## Findings

### Reconnaissance Results
MD
    
    # Add subdomains
    if [ -f "$results_dir/subdomains.txt" ] && [ -s "$results_dir/subdomains.txt" ]; then
        subdomain_count=$(wc -l < "$results_dir/subdomains.txt")
        cat >> "$report_file" << MD
#### Subdomain Enumeration
**Status**: $subdomain_count subdomains found

\`\`\`
$(head -15 "$results_dir/subdomains.txt")
\`\`\`

MD
    fi
    
    # Add port scan results
    if [ -f "$results_dir/ports.txt" ] && [ -s "$results_dir/ports.txt" ]; then
        cat >> "$report_file" << MD
#### Open Ports
\`\`\`
$(cat "$results_dir/ports.txt")
\`\`\`

MD
    fi
    
    # Add vulnerabilities
    cat >> "$report_file" << MD
### Vulnerability Assessment
MD
    
    vuln_files=("xss_vulnerabilities.txt" "sqli_vulnerabilities.txt" "lfi_vulnerabilities.txt")
    found_vulns=0
    
    for vuln_file in "${vuln_files[@]}"; do
        if [ -f "$results_dir/$vuln_file" ] && [ -s "$results_dir/$vuln_file" ]; then
            vuln_type=$(echo "$vuln_file" | sed 's/_vulnerabilities\.txt//' | tr 'a-z' 'A-Z')
            vuln_count=$(wc -l < "$results_dir/$vuln_file")
            cat >> "$report_file" << MD
#### $vuln_type
- **Severity**: High
- **Count**: $vuln_count potential vulnerabilities
- **File**: \`$vuln_file\`

MD
            ((found_vulns++))
        fi
    done
    
    if [ $found_vulns -eq 0 ]; then
        cat >> "$report_file" << MD
#### No Critical Vulnerabilities
No critical vulnerabilities were detected during the automated scan.

MD
    fi
    
    cat >> "$report_file" << MD
## Recommendations

### Immediate Actions
1. Review all identified findings
2. Patch any discovered vulnerabilities
3. Implement security monitoring

### Security Improvements
- Implement Web Application Firewall (WAF)
- Regular security audits
- Update and patch all software components
- Security awareness training

### Long-term Strategy
- Implement Security Development Lifecycle (SDL)
- Continuous security testing
- Incident response planning

## Appendix

### Scan Files
MD
    
    for file in "$results_dir"/*.txt; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            filesize=$(du -h "$file" 2>/dev/null | cut -f1) || filesize="N/A"
            cat >> "$report_file" << MD
- \`$filename\` ($filesize)

MD
        fi
    done
    
    cat >> "$report_file" << MD
### Tools Used
- BugBounty - quantum v1.0
- Automated scanning scripts
- Custom reconnaissance tools

---

*Report generated on $current_date*  
*Confidential - For authorized personnel only*
MD
}
