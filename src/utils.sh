#!/bin/bash

# Utility Functions for BugBounty

source src/config.sh

# Function to check internet connectivity
check_internet() {
    print_status "Checking internet connection..." "info"
    
    if ping -c 1 google.com &> /dev/null; then
        print_status "Internet connection: OK" "success"
        return 0
    else
        print_status "No internet connection!" "error"
        return 1
    fi
}

# Function to validate IP address
validate_ip() {
    local ip="$1"
    
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Function to validate URL
validate_url() {
    local url="$1"
    
    if [[ $url =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        return 0
    else
        return 1
    fi
}

# Function to extract domain from URL
extract_domain() {
    local url="$1"
    
    # Remove protocol
    url="${url#http://}"
    url="${url#https://}"
    
    # Remove path and query string
    url="${url%%/*}"
    
    echo "$url"
}

# Function to generate random string
generate_random_string() {
    local length="${1:-10}"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Function to create backup
create_backup() {
    local file="$1"
    local backup_dir="${2:-$BASE_DIR/backups}"
    
    mkdir -p "$backup_dir"
    
    if [ -f "$file" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_file="$backup_dir/$(basename "$file")_$timestamp.bak"
        cp "$file" "$backup_file"
        print_status "Backup created: $backup_file" "success"
    else
        print_status "File not found: $file" "error"
    fi
}

# Function to display progress bar
progress_bar() {
    local duration="$1"
    local width="${2:-50}"
    
    for ((i=0; i<=width; i++)); do
        percent=$((i * 100 / width))
        printf "\r["
        for ((j=0; j<i; j++)); do printf "█"; done
        for ((j=i; j<width; j++)); do printf " "; done
        printf "] %3d%%" "$percent"
        sleep "$duration"
    done
    printf "\n"
}

# Function to clean up temporary files
cleanup_temp() {
    print_status "Cleaning up temporary files..." "info"
    
    # Remove temporary files older than 1 day
    find /tmp -name "bugbounty_*" -mtime +1 -delete 2>/dev/null
    find /tmp -name "quantum_*" -mtime +1 -delete 2>/dev/null
    
    # Clean up empty directories in results
    find "$RESULTS_DIR" -type d -empty -delete 2>/dev/null
    
    print_status "Cleanup completed" "success"
}

# Function to check file size
check_file_size() {
    local file="$1"
    local max_size="${2:-10485760}" # 10MB default
    
    if [ -f "$file" ]; then
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        
        if [ "$size" -gt "$max_size" ]; then
            print_status "File $file is too large: $(($size/1024/1024))MB" "warning"
            return 1
        else
            return 0
        fi
    else
        return 2
    fi
}

# Function to count lines in file
count_lines() {
    local file="$1"
    
    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to get public IP
get_public_ip() {
    curl -s https://api.ipify.org
}

# Function to get geolocation info
get_geolocation() {
    local ip="${1:-$(get_public_ip)}"
    
    if [ -z "$ip" ]; then
        print_status "Could not get IP address" "error"
        return 1
    fi
    
    curl -s "http://ip-api.com/json/$ip" | python3 -m json.tool 2>/dev/null || \
    echo "IP: $ip"
}

# Function to create timestamp
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to format file size
format_size() {
    local size="$1"
    
    if [ "$size" -ge 1073741824 ]; then
        echo "$(($size/1073741824)) GB"
    elif [ "$size" -ge 1048576 ]; then
        echo "$(($size/1048576)) MB"
    elif [ "$size" -ge 1024 ]; then
        echo "$(($size/1024)) KB"
    else
        echo "$size bytes"
    fi
}

# Function to create directory if not exists
ensure_dir() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_status "Created directory: $dir" "info"
    fi
}

# Function to check if running in Termux
is_termux() {
    if [ -d "/data/data/com.termux/files/usr" ]; then
        return 0
    else
        return 1
    fi
}

# Function to display system info
system_info() {
    echo -e "${CYAN}[*] System Information${NC}"
    echo -e "${CYAN}──────────────────────${NC}"
    
    if is_termux; then
        echo -e "Platform: ${GREEN}Termux${NC}"
    else
        echo -e "Platform: ${GREEN}Linux${NC}"
    fi
    
    echo -e "Kernel: $(uname -r)"
    echo -e "Architecture: $(uname -m)"
    echo -e "Hostname: $(hostname)"
    echo -e "User: $(whoami)"
    
    if command_exists free; then
        echo -e "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    fi
    
    if command_exists df; then
        echo -e "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    fi
}

# Function to check disk space
check_disk_space() {
    local path="${1:-$BASE_DIR}"
    local threshold="${2:-90}" # Percentage
    
    local usage=$(df "$path" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -gt "$threshold" ]; then
        print_status "Low disk space: ${usage}% used" "warning"
        return 1
    else
        print_status "Disk space: ${usage}% used" "info"
        return 0
    fi
}

# Function to send notification
send_notification() {
    local message="$1"
    local title="${2:-BugBounty Notification}"
    
    if is_termux; then
        termux-notification -t "$title" -c "$message"
    elif command_exists notify-send; then
        notify-send "$title" "$message"
    else
        echo -e "${YELLOW}[!] $title: $message${NC}"
    fi
}
