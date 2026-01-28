# BugBounty - quantum v1.0

![Banner](https://github.com/AiiSima/BugBounty/blob/main/assets/c805c5ba2ef0b22a51b9efc3ea21c1e3.jpg)

A comprehensive bug bounty automation tool for penetration testers and security researchers. Built with Bash scripting for Termux and Linux systems.

## Features

### 🎯 Reconnaissance
- Subdomain enumeration
- Port scanning with service detection
- Web crawling
- WHOIS lookup
- DNS information gathering

### 🔍 Vulnerability Scanning
- XSS (Cross-Site Scripting) detection
- SQL Injection testing
- LFI/RFI (Local/Remote File Inclusion) scanning
- Full vulnerability assessment

### ⚡ Exploit Finder
- Search exploits by service/application
- CVE vulnerability lookup
- Metasploit module search
- Searchsploit integration

### 📊 Reporting
- HTML report generation
- Text report export
- Markdown documentation
- Customizable templates

## Installation

### Termux
```bash
pkg install git php curl wget
git clone --depth=1 https://github.com/AiiSima/BugBounty.git
cd BugBounty
bash quantum.sh
