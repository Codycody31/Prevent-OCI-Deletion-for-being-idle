#!/bin/bash

# Run this script using a "screen" (# apt install screen) ($ man screen)

# Define the lockfile path
LOCKFILE="/tmp/startPointlessProcesses.lock"

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
log_file="$SCRIPT_DIR/log/trackPointlessWork.log"

# Check if lockfile exists
if [ -e "$LOCKFILE" ]; then
    echo "Another instance of the script is already running. Exiting." >> "$log_file"
    exit 0
fi

# Create lockfile
touch "$LOCKFILE"

# Ensure that lockfile is removed when script exits
trap "rm -f $LOCKFILE" EXIT

# Change directory to the script's directory
cd "$SCRIPT_DIR" || exit

# Function to calculate the current CPU load
get_cpu_load() {
    echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
}

# Log script startup
echo "Starting startPointlessProcesses.sh at $(date). Monitoring CPU Load..." >> "$log_file"

# If log file is too big, truncate it
if [ $(wc -c <"$log_file") -gt 1000000 ]; then
    # Make var that is the filename with the date appended
    OLDLOGFILE="trackPointlessWork-$(date +"%Y-%m-%d-%H-%M-%S").log"

    # Copy the file to a new file
    cp "$log_file" "$OLDLOGFILE"

    # Log the truncation
    echo "Log file is too big. Moving to $OLDLOGFILE and truncating." >> "$log_file"
fi

# Main loop
while true; do
    # Get current CPU load
    currentCpuLoad=$(get_cpu_load)
    echo "Current CPU Load at $(date): $currentCpuLoad%" >> "$log_file"

    # if CPU load is below 20%, spawn 5 instances of cpuUser.sh
    if [ $currentCpuLoad -le 20 ]; then  # Adjusted the threshold to 20% for some buffer
        echo "CPU Load below threshold at $(date). Spawning 5 instances of cpuUser.sh." >> "$log_file"
        
        # Spawn 5 instances of cpuUser.sh concurrently
        for i in {1..5}; do
            /bin/bash "$SCRIPT_DIR/cpuUser.sh" &
        done
        
        wait  # Wait for all spawned scripts to complete
        
        echo "Completed running cpuUser.sh instances at $(date)." >> "$log_file"
    else
        echo "CPU Load is within acceptable range at $(date). No action taken." >> "$log_file"
    fi
    
    sleep 10  # 10-second delay between checks
done
