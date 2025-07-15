#!/bin/bash

# Default values
CHECK_INTERVAL=60  # seconds
LOG_DIR="./logs"
declare -A TARGETS
PING_COUNT=3
PING_TIMEOUT=2
HTTP_TIMEOUT=5
HTTP_METHOD="GET"
CURRENT_STATUS="unknown"
OUTAGE_START=0
VERBOSE=0

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to handle cleanup and exit
cleanup() {
    local exit_code=$?
    local signal=$1
    
    console_log "$YELLOW" "Received signal $signal. Stopping connection monitor..."
    
    # Kill any background processes that might be hanging
    jobs -p | xargs -r kill -9 2>/dev/null
    
    # Final log message
    if [[ -n "$GENERAL_LOG" && -f "$GENERAL_LOG" ]]; then
        log_message "$GENERAL_LOG" "monitor_stopped"
    fi
    
    console_log "$BLUE" "Connection monitor stopped"
    exit $exit_code
}

# Set up signal traps for graceful termination
trap 'cleanup SIGINT' INT
trap 'cleanup SIGTERM' TERM
trap 'cleanup SIGHUP' HUP

# Function to display help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Monitor connection status using configurable methods."
    echo
    echo "Options:"
    echo "  -i, --interval SECONDS    Check interval in seconds (default: 60)"
    echo "  -d, --log-dir DIR         Directory to store logs (default: ./logs)"
    echo "  -p, --ping TARGET         Add ICMP ping target (can be used multiple times)"
    echo "  -h, --http TARGET         Add HTTP target (can be used multiple times)"
    echo "  --ping-count COUNT        Number of ICMP pings (default: 3)"
    echo "  --ping-timeout SEC        ICMP ping timeout in seconds (default: 2)"
    echo "  --http-timeout SEC        HTTP request timeout in seconds (default: 5)"
    echo "  -v, --verbose             Display verbose output"
    echo "  --help                    Display this help message"
    echo
    echo "Example:"
    echo "  $0 --interval 30 --ping 8.8.8.8 --ping 1.1.1.1 --http google.com --http https://example.com"
    exit 0
}

# Parse command-line arguments
parse_arguments() {
    # Initialize target arrays
    TARGETS["icmp"]=""
    TARGETS["http"]=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interval)
                CHECK_INTERVAL="$2"
                shift 2
                ;;
            -d|--log-dir)
                LOG_DIR="$2"
                shift 2
                ;;
            -p|--ping)
                TARGETS["icmp"]="${TARGETS["icmp"]} $2"
                shift 2
                ;;
            -h|--http)
                TARGETS["http"]="${TARGETS["http"]} $2"
                shift 2
                ;;
            --ping-count)
                PING_COUNT="$2"
                shift 2
                ;;
            --ping-timeout)
                PING_TIMEOUT="$2"
                shift 2
                ;;
            --http-timeout)
                HTTP_TIMEOUT="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            --help)
                show_help
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                ;;
        esac
    done
    
    # Add default ping target if no targets specified
    if [[ -z "${TARGETS["icmp"]}" && -z "${TARGETS["http"]}" ]]; then
        TARGETS["icmp"]="8.8.8.8"
    fi
    
    # Trim leading whitespace
    for method in "${!TARGETS[@]}"; do
        TARGETS[$method]=$(echo "${TARGETS[$method]}" | xargs)
    done
}

# Function to set up log directories and files
setup_logs() {
    mkdir -p "$LOG_DIR"
    
    # Generate timestamp prefix for log files
    TIMESTAMP_PREFIX=$(date '+%Y-%m-%d_%H-%M-%S')
    
    OUTAGE_LOG="$LOG_DIR/${TIMESTAMP_PREFIX}_outage.log"
    GENERAL_LOG="$LOG_DIR/${TIMESTAMP_PREFIX}_connection.log"
    
    # Create a mapping of targets to their log files
    declare -gA TARGET_LOG_FILES
    
    # Initialize log files if they don't exist
    for method in "${!TARGETS[@]}"; do
        if [[ -n "${TARGETS[$method]}" ]]; then
            for target in ${TARGETS[$method]}; do
                target_file=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
                log_file="$LOG_DIR/${TIMESTAMP_PREFIX}_${method}_${target_file}.log"
                TARGET_LOG_FILES["${method}_${target_file}"]="$log_file"
                touch "$log_file"
            done
        fi
    done
    
    touch "$OUTAGE_LOG"
    touch "$GENERAL_LOG"
}

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$1"
    local message="$2"
    echo "$timestamp,$message" >> "$log_file"
}

# Function to log colored console messages
console_log() {
    local color="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${color}[$timestamp] $message${NC}"
}

# Function to perform ICMP check
check_icmp() {
    local target="$1"
    local target_file=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
    local log_file="${TARGET_LOG_FILES["icmp_${target_file}"]}"
    local result
    
    # Ping with low timeout
    if ping -c "$PING_COUNT" -W "$PING_TIMEOUT" "$target" > /dev/null 2>&1; then
        result="success"
        [[ $VERBOSE -eq 1 ]] && console_log "$GREEN" "ICMP check to $target: Success"
    else
        result="failure"
        console_log "$RED" "ICMP check to $target: Failed"
    fi
    
    # Log the result
    local latency=$(ping -c 1 -W "$PING_TIMEOUT" "$target" 2>/dev/null | grep "time=" | cut -d "=" -f 4 | cut -d " " -f 1 || echo "timeout")
    log_message "$log_file" "$result,$latency"
    
    [[ "$result" == "success" ]] && return 0 || return 1
}

# Function to perform HTTP check
check_http() {
    local target="$1"
    local target_file=$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')
    local log_file="${TARGET_LOG_FILES["http_${target_file}"]}"
    local result
    local start_time
    local end_time
    local duration
    
    # Add http:// prefix if not present and not https://
    [[ "$target" != http://* && "$target" != https://* ]] && target="http://$target"
    
    # Measure response time
    start_time=$(date +%s.%N)
    if curl -s --head --location --connect-timeout "$HTTP_TIMEOUT" -m "$HTTP_TIMEOUT" "$target" > /dev/null 2>&1; then
        result="success"
        [[ $VERBOSE -eq 1 ]] && console_log "$GREEN" "HTTP check to $target: Success"
    else
        result="failure"
        console_log "$RED" "HTTP check to $target: Failed"
    fi
    end_time=$(date +%s.%N)
    
    # Calculate duration in milliseconds
    duration=$(echo "($end_time - $start_time) * 1000" | bc | cut -d "." -f 1)
    
    # Log the result
    log_message "$log_file" "$result,$duration"
    
    [[ "$result" == "success" ]] && return 0 || return 1
}

# Function to run all configured checks
run_checks() {
    local all_success=true
    
    for method in "${!TARGETS[@]}"; do
        if [[ -n "${TARGETS[$method]}" ]]; then
            for target in ${TARGETS[$method]}; do
                case "$method" in
                    icmp)
                        check_icmp "$target" || all_success=false
                        ;;
                    http)
                        check_http "$target" || all_success=false
                        ;;
                    *)
                        console_log "$YELLOW" "Unknown check method: $method"
                        ;;
                esac
            done
        fi
    done
    
    # Log overall status
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local status
    
    if $all_success; then
        status="UP"
        log_message "$GENERAL_LOG" "up"
    else
        status="DOWN"
        log_message "$GENERAL_LOG" "down"
    fi
    
    update_connection_status "$all_success"
    
    return $([[ "$all_success" == "true" ]] && echo 0 || echo 1)
}

# Function to update connection status and handle outage logging
update_connection_status() {
    local is_up=$1
    local current_time=$(date +%s)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$is_up" == "true" ]]; then
        if [[ "$CURRENT_STATUS" == "down" ]]; then
            # Connection restored after being down
            local outage_duration=$((current_time - OUTAGE_START))
            local outage_msg="Connection restored after being down for ${outage_duration} seconds"
            log_message "$OUTAGE_LOG" "restored,$outage_duration"
            console_log "$GREEN" "$outage_msg"
            CURRENT_STATUS="up"
        elif [[ "$CURRENT_STATUS" == "unknown" ]]; then
            # Initial state is up
            console_log "$GREEN" "Initial connection check successful"
            CURRENT_STATUS="up"
        fi
    else
        if [[ "$CURRENT_STATUS" == "up" || "$CURRENT_STATUS" == "unknown" ]]; then
            # Connection just went down
            OUTAGE_START=$current_time
            log_message "$OUTAGE_LOG" "outage_start,0"
            console_log "$RED" "Connection DOWN detected"
            CURRENT_STATUS="down"
        fi
    fi
}

# Main function to start monitoring
start_monitoring() {
    console_log "$BLUE" "Starting connection monitoring"
    console_log "$BLUE" "Check interval: $CHECK_INTERVAL seconds"
    console_log "$BLUE" "Press Ctrl+C to stop monitoring"
    
    # Display targets for each method
    for method in "${!TARGETS[@]}"; do
        if [[ -n "${TARGETS[$method]}" ]]; then
            console_log "$BLUE" "${method^^} targets: ${TARGETS[$method]}"
        fi
    done
    
    console_log "$BLUE" "Logs directory: $LOG_DIR"
    
    while true; do
        run_checks
        # Use smaller sleep intervals with a counter to allow faster script termination
        for ((i=0; i<CHECK_INTERVAL; i++)); do
            sleep 1
        done
    done
}

# Main execution
parse_arguments "$@"
setup_logs
start_monitoring
