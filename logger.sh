#!/bin/bash

# Set strict mode
set -euo pipefail

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Log levels
declare -rA LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
LOG_LEVEL="${LOG_LEVEL:-INFO}" # Default to INFO if not set

# Logging utility functions
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_level_numeric() {
    echo "${LOG_LEVELS[$1]:-${LOG_LEVELS[INFO]}}"
}

should_log() {
    local level=$1
    local current_level_num=$(log_level_numeric "$LOG_LEVEL")
    local requested_level_num=$(log_level_numeric "$level")
    [[ $requested_level_num -ge $current_level_num ]]
}

# Main logging functions
log_debug() {
    if should_log "DEBUG"; then
        echo -e "${GRAY}[DEBUG] $(timestamp) - $*${NC}" >&2
    fi
}

log_info() {
    if should_log "INFO"; then
        echo -e "${GREEN}[INFO]${NC} $(timestamp) - $*"
    fi
}

log_warn() {
    if should_log "WARN"; then
        echo -e "${YELLOW}[WARN]${NC} $(timestamp) - $*" >&2
    fi
}

log_error() {
    if should_log "ERROR"; then
        echo -e "${RED}[ERROR]${NC} $(timestamp) - $*" >&2
    fi
}

log_fatal() {
    if should_log "FATAL"; then
        echo -e "${RED}${BOLD}[FATAL]${NC} $(timestamp) - $*" >&2
        exit 1
    fi
}

# Special purpose logging functions
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(timestamp) - $*"
}

log_header() {
    echo -e "\n${BLUE}${BOLD}=== $* ===${NC}\n"
}

log_section() {
    echo -e "\n${CYAN}--- $* ---${NC}"
}

# Progress indicator functions
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r["
    printf "%${completed}s" | tr " " "="
    printf "%${remaining}s" | tr " " " "
    printf "] %d%%" $percentage
}

# Example usage function
log_example() {
    echo "Logger Usage Examples:"
    echo "---------------------"
    echo "log_debug 'Debugging information'"
    echo "log_info 'General information'"
    echo "log_warn 'Warning message'"
    echo "log_error 'Error message'"
    echo "log_fatal 'Fatal error message'"
    echo "log_success 'Success message'"
    echo "log_header 'Main Section Header'"
    echo "log_section 'Sub Section Header'"
    echo
    echo "Set log level: export LOG_LEVEL=DEBUG|INFO|WARN|ERROR|FATAL"
}

# Test function to demonstrate all log types
test_logger() {
    log_header "Testing Logger"
    log_debug "This is a debug message"
    log_info "This is an info message"
    log_warn "This is a warning message"
    log_error "This is an error message"
    log_success "This is a success message"
    log_section "This is a section header"

    echo "Testing progress bar:"
    for i in {1..10}; do
        progress_bar $i 10
        sleep 0.2
    done
    echo -e "\nDone!"
}

# If the script is run directly (not sourced), show example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_logger
fi