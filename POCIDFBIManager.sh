#!/bin/bash

# Define the lockfile path
LOCKFILE="/tmp/POCIDFBIManager.lock"

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
LOG_DIR="$SCRIPT_DIR/log"
LOG_FILE="$LOG_DIR/POCIDFBITrack.log"

# Default values
WORKER_COUNT=5
CPU_THRESHOLD=20
LOGGING_ENABLED=true
DURATION_BETWEEN_CHECKS=10 # In seconds

# Configuration file path
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Read from configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to validate if the provided input is a number
is_number() {
    local num="$1"
    # Use regex to check if the input is a number
    [[ $num =~ ^[0-9]+$ ]]
}

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo "  -w  Set the worker count. (Default: $WORKER_COUNT)"
    echo "  -c  Set the CPU threshold. (Default: $CPU_THRESHOLD)"
    echo "  -n  Disable logging to the log file."
    echo "  -h  Display this help message."
}

# Check for --help option
if [[ " $* " == *" --help "* ]]; then
    display_help
    exit 0
fi

# Parse command-line arguments
while getopts ":w:c:d:nh" opt; do
    case $opt in
    w)
        if is_number "$OPTARG"; then
            WORKER_COUNT=$OPTARG
        else
            echo "Error: -w argument '$OPTARG' is not a valid number." >&2
            exit 1
        fi
        ;;
    c)
        if is_number "$OPTARG"; then
            CPU_THRESHOLD=$OPTARG
        else
            echo "Error: -c argument '$OPTARG' is not a valid number." >&2
            exit 1
        fi
        ;;
    d)
        if is_number "$OPTARG"; then
            DURATION_BETWEEN_CHECKS=$OPTARG
        else
            echo "Error: -d argument '$OPTARG' is not a valid number." >&2
            exit 1
        fi
        ;;
    n)
        LOGGING_ENABLED=false
        ;;
    h)
        display_help
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

# Ensure that the log directory exists
mkdir -p "$SCRIPT_DIR/log"

# Function to calculate the current CPU load
get_cpu_load() {
    echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
}

# Function to log to the log file and to stdout
log() {
    local message="$1"
    local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
    local formatted_message="[$timestamp] $message"
    if [ "$LOGGING_ENABLED" = true ]; then
        echo "$formatted_message" | tee -a "$LOG_FILE"
    else
        echo "$formatted_message"
    fi
}

# Function to clean up the log file
cleanup_log() {
    # If log file is too big, truncate it
    if [ "$(wc -c <"$LOG_FILE")" -gt 1000000 ]; then
        # Make var that is the filename with the date appended
        OLDLOGFILE="$LOG_DIR/POCIDFBITrack-$(date +"%Y-%m-%d-%H-%M-%S").log"

        # Copy the file to a new file
        cp "$LOG_FILE" "$OLDLOGFILE"

        # Log the truncation
        log "Log file is too big. Moving to $OLDLOGFILE and truncating."

        # Truncate the log file
        truncate -s 0 "$LOG_FILE"
    fi
}

# Function to cleanup when the script exits
exit_handler() {
    printf "\n"
    # Kill all spawned waste workers
    log "Killing all spawned waste workers..."
    # TODO: Might need to ensure the parent who spawned it is a POCIDFBIManager.sh instance
    pkill -f WasteCPUWorker.sh
    pkill -f WasteMemoryWorker.sh

    # Remove lockfile
    log "Removing lockfile..."
    rm -f "$LOCKFILE"

    # Log script exit
    log "Exiting POCIDFBIManager.sh at $(date)."
    exit 1
}

# Trap specific signals and run the exit_handler
trap exit_handler SIGINT SIGTERM

# Check if lockfile exists
if [ -e "$LOCKFILE" ]; then
    log "Another instance of the POCIDFBIManager.sh script is already running. Exiting."
    exit 0
fi

# Create lockfile
touch "$LOCKFILE"

# Ensure that lockfile is removed when script exits
trap 'rm -f $LOCKFILE' EXIT

# Change directory to the script's directory
cd "$SCRIPT_DIR" || exit

# Log script startup
log "Starting POCIDFBIManager.sh at $(date). Monitoring CPU Load..."

# Log current configuration
log "Script will trigger when CPU load is below $CPU_THRESHOLD% and will spawn $WORKER_COUNT instances of cpu workers."

# Main loop
while true; do
    # Get current CPU load
    currentCpuLoad=$(get_cpu_load)
    log "Current CPU Load at $(date): $currentCpuLoad%"

    # if CPU load is below X%, spawn Y instances of WasteCPUWorker.sh
    if [ "$currentCpuLoad" -le "$CPU_THRESHOLD" ]; then # Adjusted the threshold to 20% for some buffer
        log "CPU Load below threshold at $(date). Spawning $WORKER_COUNT instances of waste workers..."

        # Spawn instances of the specified worker(s) concurrently
        for _ in $(seq 1 "$WORKER_COUNT"); do
            /bin/bash "$SCRIPT_DIR/workers/WasteCPUWorker.sh" &
        done

        wait # Wait for all spawned scripts to complete

        log "Completed running $WORKER_COUNT instances of waste workers at $(date)."
    else
        log "CPU Load is within acceptable range at $(date). No action taken."
    fi

    # Random chance to run the cleanup_log function
    if [ "$((RANDOM % 100))" -lt 5 ]; then
        cleanup_log
    fi

    sleep "$DURATION_BETWEEN_CHECKS"
done
