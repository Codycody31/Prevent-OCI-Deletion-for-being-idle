#!/bin/bash

# Run this script using a "screen" (# apt install screen) ($ man screen)

# Define the lockfile path
LOCKFILE="/tmp/POCIDFBIManager.lock"

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
log_file="$SCRIPT_DIR/log/POCIDFBITrack.log"

# Ensure that the log directory exists
mkdir -p "$SCRIPT_DIR/log"

# Function to calculate the current CPU load
get_cpu_load() {
    echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
}

# Function to log to the log file and to stdout
log() {
    echo "$1" >>"$log_file"
    echo "$1"
}

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

# If log file is too big, truncate it
if [ "$(wc -c <"$log_file")" -gt 1000000 ]; then
    # Make var that is the filename with the date appended
    OLDLOGFILE="POCIDFBITrack-$(date +"%Y-%m-%d-%H-%M-%S").log"

    # Copy the file to a new file
    cp "$log_file" "$OLDLOGFILE"

    # Log the truncation
    log "Log file is too big. Moving to $OLDLOGFILE and truncating."
fi

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

    sleep 10 # 10-second delay between checks
done
