#!/bin/bash

# Define the lockfile path
LOCKFILE="/tmp/POCIDFBIManager.lock"

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
LOG_DIR="$SCRIPT_DIR/log"
LOG_FILE="$LOG_DIR/POCIDFBITrack.log"

# Ensure that the log directory exists
mkdir -p "$SCRIPT_DIR/log"

# Function to calculate the current CPU load
get_cpu_load() {
    echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
}

# Function to log to the log file and to stdout
log() {
    echo "$1" >>"$LOG_FILE"
    echo "$1"
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
    # Kill all spawned waste workers
    log "Killing all spawned WasteCPUWorker.sh instances..."
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

# Main loop
while true; do
    # Get current CPU load
    currentCpuLoad=$(get_cpu_load)
    log "Current CPU Load at $(date): $currentCpuLoad%"

    # if CPU load is below 20%, spawn 5 instances of WasteCPUWorker.sh
    if [ "$currentCpuLoad" -le 20 ]; then # Adjusted the threshold to 20% for some buffer
        log "CPU Load below threshold at $(date). Spawning 5 instances of WasteCPUWorker.sh."

        # Spawn 5 instances of WasteCPUWorker.sh concurrently
        for _ in {1..5}; do
            /bin/bash "$SCRIPT_DIR/workers/WasteCPUWorker.sh" &
        done

        wait # Wait for all spawned scripts to complete

        log "Completed running WasteCPUWorker.sh instances at $(date)."
    else
        log "CPU Load is within acceptable range at $(date). No action taken."
    fi

    # Random chance to run the cleanup_log function
    if [ "$((RANDOM % 100))" -lt 5 ]; then
        cleanup_log
    fi

    sleep 10 # 10-second delay between checks
done
