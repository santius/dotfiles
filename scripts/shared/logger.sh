#!/bin/bash

# Disable strict mode temporarily for variable declarations
set +u 2>/dev/null || true

# ANSI color codes (guarded so re-sourcing is safe)
[[ -n "${RED-}" ]]    || readonly RED='\033[0;31m'
[[ -n "${GREEN-}" ]]  || readonly GREEN='\033[0;32m'
[[ -n "${YELLOW-}" ]] || readonly YELLOW='\033[1;33m'
[[ -n "${BLUE-}" ]]   || readonly BLUE='\033[0;34m'
[[ -n "${PURPLE-}" ]] || readonly PURPLE='\033[0;35m'
[[ -n "${CYAN-}" ]]   || readonly CYAN='\033[0;36m'
[[ -n "${GRAY-}" ]]   || readonly GRAY='\033[0;90m'
[[ -n "${NC-}" ]]     || readonly NC='\033[0m' # No Color
[[ -n "${BOLD-}" ]]   || readonly BOLD='\033[1m'

# Initialize LOG_LEVEL first
: "${LOG_LEVEL:=INFO}"

# Log levels with default value (using simple variables instead of associative array)
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_FATAL=4

# Now that all variables are declared, enable strict mode
set -euo pipefail

# Logging utility functions
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_level_numeric() {
    local level="${1:-INFO}"
    case "$level" in
        "DEBUG") echo "$LOG_LEVEL_DEBUG" ;;
        "INFO")  echo "$LOG_LEVEL_INFO" ;;
        "WARN")  echo "$LOG_LEVEL_WARN" ;;
        "ERROR") echo "$LOG_LEVEL_ERROR" ;;
        "FATAL") echo "$LOG_LEVEL_FATAL" ;;
        *)       echo "$LOG_LEVEL_INFO" ;;
    esac
}

should_log() {
    local level="${1:-INFO}"
    local current_level_num
    local requested_level_num

    current_level_num=$(log_level_numeric "$LOG_LEVEL")
    requested_level_num=$(log_level_numeric "$level")

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
    local spinstr="|/-\\"
    while ps -p "$pid" > /dev/null; do
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
        progress_bar "$i" 10
        sleep 0.2
    done
    echo -e "\nDone!"
}

# If the script is run directly (not sourced), show example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_logger
fi
